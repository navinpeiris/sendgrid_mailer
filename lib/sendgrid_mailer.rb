require 'sendgrid_mailer/railtie'
require 'sendgrid_mailer/config'
require 'sendgrid_mailer/version'

require 'sendgrid-ruby'

class SendGridMailer
  include SendGrid

  class Error < StandardError; end
  class ConfigurationError < Error; end
  class DeliveryError < Error
    attr_reader :response

    def initialize(response)
      super('An error occurred while delivering this email. See response for more details.')

      @response = response
    end
  end

  def self.defaults
    @defaults || {}
  end

  def self.default(args)
    @defaults ||= {}
    @defaults.merge!(args)
  end

  def self.method_missing(method, *args)
    if instance_methods.include?(method.to_sym)
      new.method(method).call(*args)
    else
      super
    end
  end

  def self.respond_to_missing?(method_name, include_private = false)
    instance_methods.include?(method.to_sym) || super
  end

  def mailer(template_id: nil, # rubocop:disable Metrics/ParameterLists, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
             from: nil,
             from_name: nil,
             subject: nil,
             to: nil,
             dynamic_template_data: nil,
             open_tracking: nil,
             click_tracking: nil)
    self.template_id = template_id if template_id
    self.from = from if from
    self.from_name = from_name if from_name
    self.subject = subject if subject

    self.open_tracking(open_tracking) unless open_tracking.nil?
    self.click_tracking(click_tracking) unless click_tracking.nil?

    add_personalization(to, dynamic_template_data: dynamic_template_data) if to

    self
  end

  def template_id
    sg_mail.template_id
  end

  def template_id=(template_id)
    sg_mail.template_id = template_id
  end

  def from
    sg_mail.from['email']
  end

  def from=(email)
    sg_mail.from = Email.new(email: email, name: from_name)
  end

  def from_name
    sg_mail.from['name']
  end

  def from_name=(name)
    sg_mail.from = Email.new(email: from, name: name)
  end

  def subject
    sg_mail.subject
  end

  def subject=(subject)
    sg_mail.subject = subject
  end

  def personalizations
    sg_mail.personalizations
  end

  def add_personalization(to, dynamic_template_data: nil)
    personalization = Personalization.new

    add_to_email_to_personalization personalization, to

    personalization.add_dynamic_template_data dynamic_template_data if dynamic_template_data

    sg_mail.add_personalization personalization
  end

  def tracking_settings
    sg_mail.instance_variable_get(:@tracking_settings)
  end

  def open_tracking(enable, substitution_tag: nil)
    tracking_settings.open_tracking =
      OpenTracking.new enable: enable, substitution_tag: substitution_tag
  end

  def click_tracking(enable, enable_text: nil)
    tracking_settings.click_tracking = ClickTracking.new enable: enable,
                                                         enable_text: enable_text
  end

  def deliver
    sg_api = SendGrid::API.new(api_key: api_key)
    response = sg_api.client.mail._('send').post(request_body: sg_mail.to_json)

    raise(DeliveryError, response) unless response.status_code.start_with?('2')
  end

  def sg_mail
    @sg_mail ||= begin
      mail = SendGrid::Mail.new

      mail.template_id = defaults[:template_id]
      mail.from = Email.new(email: defaults.fetch(:from, 'no-reply@example.com'),
                            name: defaults[:from_name])
      mail.subject = defaults[:subject]
      mail.tracking_settings = TrackingSettings.new

      mail
    end
  end

  private

  def defaults
    self.class.defaults
  end

  def api_key
    SendGridMailer.config.api_key ||
      raise(ConfigurationError, 'SendGridMailer needs to be configured with an API key')
  end

  def add_to_email_to_personalization(personalization, to)
    if to.is_a?(Array)
      to.each { |t| add_to_email_to_personalization(personalization, t) }
    elsif to.is_a?(Hash)
      personalization.add_to Email.new(to)
    else
      personalization.add_to Email.new(email: to)
    end
  end
end
