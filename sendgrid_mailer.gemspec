# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sendgrid_mailer/version'

Gem::Specification.new do |spec|
  spec.name          = 'sendgrid_mailer'
  spec.version       = SendGridMailer::VERSION
  spec.authors       = ['Navin Peiris']
  spec.email         = ['navinpeiris@gmail.com']

  spec.summary       = 'Send template & content based emails through SendGrid'
  spec.description   = 'Rails mailer for sending template & content based emails through SendGrid'
  spec.homepage      = 'https://github.com/sendgrid_mailer'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'

  spec.add_development_dependency 'rspec', '~> 3.0'
end
