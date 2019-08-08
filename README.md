# SendGrid Mailer

Rails mailer for sending template & content based emails through SendGrid

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sendgrid_mailer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sendgrid_mailer

## Usage

### Configuration

Configure the SendGrid API key to be used by the mailer by placing the following in the `config/initializers/sendgrid_mailer.rb` file:

```ruby
SendGridMailer.configure do |config|
  config.api_key = ENV['SENDGRID_API_KEY']
end
```

### Adding a new mailer

A new mailer can be created similar to the way you create a typical Rails mailer, for example:

```ruby
class AccountMailer < SendGridMailer
  # Optionally provide defaults by either specifying an attribute at a time or multiple
  default from: 'support@example.com', from_name: 'Hello from Example'

  def welcome_email(user)
    mailer template_id: 'sendgrid-template-id',
           from: 'hello@example.com', # Defaults can be overridden here
           subject: 'Welcome to Example App',
           to: user.email, # Can be email, `{email: user.email, name: user.name}` hash, or an array containing either
           dynamic_template_data: {
               homepage_url: "http://example.com/#{user.handle}"
           },
           open_tracking: true, # optional
           click_tracking: true # optional
  end

  def newsletter(users)
    users.each do |user|
      # Add personalizations for multiple users like below:
      add_personalization user.email,
                          dynamic_template_data: {
                              homepage_url: "http://example.com/#{user.handle}"
                          }
    end

    mailer template_id: 'sendgrid-template-id',
           subject: 'Our Newsletter for Today'
  end

  def weekly_report(users)
    mailer template_id: 'sendgrid-template-id',
           subject: 'Our Newsletter for Today',
           to: users.map(&:email) # Multiple to addresses can be specified
  end
end
```

### Sending an email

Send the email by invoking the `deliver` method:

```ruby
AccountMailer.welcome_email(user).deliver
```

### Testing

To aid testing, require the `sendgrid_mailer/testing` file, which captures the emails in a `deliveries` array:

```ruby
require 'sendgrid_mailer/testing'

# ....

  it 'sends the welcome email' do
    expect(SendGridMailer.deliveries).to be_empty

    AccountMailer.welcome_email(user).deliver

    expect(SendGridMailer.deliveries.length).to eql 1

    last_email = SendGridMailer.deliveries

    expect(last_email['from']['email']).to eql 'hello@example.com'
    expect(last_email['from']['name']).to eql 'Hello'
  end

# ....

```

#### Enabling/disabling delivery capture

You can enable/disable delivery capture using the following methods:

```ruby
SendGridMailer.disable_mock!
SendGridMailer.enable_mock!
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/navinpeiris/sendgrid_mailer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SendGridMailer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/navinpeiris/sendgrid_mailer/blob/master/CODE_OF_CONDUCT.md).
