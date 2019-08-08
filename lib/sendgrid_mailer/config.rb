class SendGridMailer
  if defined?(Rails)
    def self.configure(&block)
      if block_given?
        block.call(SendGridMailer::Railtie.config.sendgrid_mailer)
      else
        SendGridMailer::Railtie.config.sendgrid_mailer
      end
    end

    def self.config
      SendGridMailer::Railtie.config.sendgrid_mailer
    end
  else
    def self.config
      @@config ||= OpenStruct.new(api_key: nil) # rubocop:disable Style/ClassVars
    end
  end
end
