require 'sendgrid_mailer/version'

require 'sendgrid-ruby'

class SendGridMailer
  include SendGrid

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

  def mail(template_id: nil,
           from: nil,
           from_name: nil,
           subject: nil)
    self.template_id = template_id if template_id
    self.from = from if from
    self.from_name = from_name if from_name
    self.subject = subject if subject

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

  def sg_mail
    @sg_mail ||= begin
      mail = SendGrid::Mail.new

      mail.template_id = defaults[:template_id]
      mail.from = Email.new(email: defaults.fetch(:from, 'no-reply@example.com'),
                            name: defaults[:from_name])
      mail.subject = defaults[:subject]

      mail
    end
  end

  private

  def defaults
    self.class.defaults
  end
end
