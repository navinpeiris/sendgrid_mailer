RSpec.describe SendGridMailer do
  let(:mailer) do
    SendGridMailer.mailer from: 'hello@example.com',
                          from_name: 'Hello',
                          to: 'recipient@example.com',
                          subject: 'This is an awesome email'
  end

  after { SendGridMailer.deliveries.clear }

  it 'captures deliveries' do
    mailer.deliver

    expect(SendGridMailer.deliveries.length).to eql 1

    last_email = SendGridMailer.deliveries.last

    expect(last_email['from']['email']).to eql 'hello@example.com'
    expect(last_email['from']['name']).to eql 'Hello'
    expect(last_email['subject']).to eql 'This is an awesome email'

    expect(last_email['personalizations'][0]['to'][0]['email']).to eql 'recipient@example.com'
  end
end
