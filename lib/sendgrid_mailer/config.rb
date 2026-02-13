require 'ostruct'

class SendGridMailer
  if defined?(Rails)
    def self.configure
      if block_given?
        yield(SendGridMailer::Railtie.config.sendgrid_mailer)
      else
        SendGridMailer::Railtie.config.sendgrid_mailer
      end
    end

    def self.config
      SendGridMailer::Railtie.config.sendgrid_mailer
    end
  else
    def self.config
      @@config ||= OpenStruct.new(api_key: nil) # rubocop:disable Style/ClassVars, Style/OpenStructUse
    end
  end
end
