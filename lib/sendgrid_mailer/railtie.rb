if defined?(Rails)
  require 'rails'
  class SendGridMailer
    class Railtie < Rails::Railtie
      config.sendgrid_mailer = ActiveSupport::OrderedOptions.new
    end
  end
end
