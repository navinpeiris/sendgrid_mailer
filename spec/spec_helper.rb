ENV['RACK_ENV'] ||= 'test'

unless ENV['COVERAGE'] == 'false'
  require 'simplecov'
  SimpleCov.start do
    minimum_coverage 95
  end
end

require 'bundler/setup'
require 'sendgrid_mailer'
require 'webmock/rspec'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
    c.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.filter_run_excluding disabled: true
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  # config.warnings = true
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.profile_examples = 10

  config.order = :random
  Kernel.srand config.seed
end
