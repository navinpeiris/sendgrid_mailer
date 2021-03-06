require 'sendgrid_mailer/railtie'
require 'sendgrid_mailer/config'
require 'sendgrid_mailer/version'

require 'sendgrid-ruby'

class SendGridMailer # rubocop:disable Metrics/ClassLength
  include SendGrid

  class Error < StandardError; end
  class ConfigurationError < Error; end
  class DeliveryError < Error
    attr_reader :response

    def initialize(response)
      super("An error occurred while delivering this email: #{response.body}")

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

  def self.method_missing(method, *args, **kwargs)
    if instance_methods.include?(method.to_sym)
      new.method(method).call(*args, **kwargs)
    else
      super
    end
  end

  def self.respond_to_missing?(method_name, include_private = false)
    instance_methods.include?(method_name.to_sym) || super
  end

  def mailer(template_id: nil, # rubocop:disable Metrics/ParameterLists, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
             from: nil,
             from_name: nil,
             reply_to: nil,
             reply_to_name: nil,
             subject: nil,
             to: nil,
             dynamic_template_data: nil,
             content_html: nil,
             content_text: nil,
             categories: nil,
             custom_args: nil,
             open_tracking: nil,
             click_tracking: nil)
    self.template_id = template_id if template_id
    self.from = from if from
    self.from_name = from_name if from_name
    self.reply_to = reply_to if reply_to
    self.reply_to_name = reply_to_name if reply_to_name
    self.subject = subject if subject
    self.categories = categories if categories

    add_html_content(content_html) if content_html
    add_text_content(content_text) if content_text

    add_personalization(to, dynamic_template_data: dynamic_template_data) if to

    add_custom_args(custom_args) if custom_args

    self.open_tracking(open_tracking) unless open_tracking.nil?
    self.click_tracking(click_tracking) unless click_tracking.nil?

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

  def reply_to
    sg_mail.reply_to&.fetch('email', nil)
  end

  def reply_to=(email)
    sg_mail.reply_to = Email.new(email: email, name: reply_to_name)
  end

  def reply_to_name
    sg_mail.reply_to&.fetch('name', nil)
  end

  def reply_to_name=(name)
    sg_mail.reply_to = Email.new(email: reply_to, name: name)
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

  def add_personalization(to, dynamic_template_data: nil, substitutions: {})
    personalization = Personalization.new

    add_to_email_to_personalization personalization, to

    personalization.add_dynamic_template_data dynamic_template_data if dynamic_template_data

    substitutions.each do |key, value|
      personalization.add_substitution(Substitution.new(key: key, value: value))
    end

    sg_mail.add_personalization personalization
  end

  def contents
    sg_mail.contents
  end

  def add_html_content(content)
    sg_mail.add_content Content.new(type: 'text/html', value: content)
  end

  def add_text_content(content)
    sg_mail.add_content Content.new(type: 'text/plain', value: content)
  end

  def categories
    sg_mail.categories
  end

  def categories=(categories)
    categories.each do |category|
      sg_mail.add_category Category.new(name: category)
    end
  end

  def custom_args
    sg_mail.custom_args
  end

  def add_custom_args(custom_args)
    custom_args.each do |key, value|
      add_custom_arg key, value
    end
  end

  def add_custom_arg(key, value)
    sg_mail.add_custom_arg CustomArg.new(key: key, value: value)
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
