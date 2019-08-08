require 'sendgrid_mailer'

class SendGridMailer
  @@mock_deliveries = true # rubocop:disable Style/ClassVars

  def self.enable_mock!
    @@mock_deliveries = true # rubocop:disable Style/ClassVars
  end

  def self.disable_mock!
    @@mock_deliveries = false # rubocop:disable Style/ClassVars
  end

  def self.mock_deliveries?
    @@mock_deliveries
  end

  def self.deliveries
    @deliveries ||= []
  end

  alias original_deliver deliver

  def deliver
    if self.class.mock_deliveries?
      self.class.deliveries << sg_mail.to_json
    else
      original_deliver
    end
  end
end
