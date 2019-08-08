RSpec.describe SendGridMailer do
  class DefaultsMailer < SendGridMailer
    default template_id: 'template-id'
    default from: 'notifications@example.com', from_name: 'Example Notifier'
    default subject: 'Hello from example'
  end

  it 'sets email fields from provided defaults' do
    mail = DefaultsMailer.mail

    expect(mail).not_to be nil

    expect(mail.template_id).to eql 'template-id'
    expect(mail.from).to eql 'notifications@example.com'
    expect(mail.from_name).to eql 'Example Notifier'
    expect(mail.subject).to eql 'Hello from example'
  end

  it 'can override defaults through mail method' do
    mail = DefaultsMailer.mail template_id: 'new-template-id',
                               from: 'two@example.com',
                               from_name: 'Two',
                               subject: 'Subject Two'

    expect(mail.template_id).to eql 'new-template-id'
    expect(mail.from).to eql 'two@example.com'
    expect(mail.from_name).to eql 'Two'
    expect(mail.subject).to eql 'Subject Two'
  end

  it 'can override just the email' do
    mail = DefaultsMailer.mail(from: 'two@example.com')

    expect(mail.from).to eql 'two@example.com'

    expect(mail.template_id).to eql 'template-id'
    expect(mail.from_name).to eql 'Example Notifier'
    expect(mail.subject).to eql 'Hello from example'
  end

  it 'can override just the name' do
    mail = DefaultsMailer.mail(from_name: 'Me Two')

    expect(mail.from_name).to eql 'Me Two'

    expect(mail.template_id).to eql 'template-id'
    expect(mail.from).to eql 'notifications@example.com'
    expect(mail.subject).to eql 'Hello from example'
  end

  it 'adds personalization if to email is provided' do
    mail = DefaultsMailer.mail(to: 'someone@example.com', dynamic_template_data: { one: '1' })

    expect(mail.personalizations.length).to eql 1

    expect(mail.personalizations[0]['to']).to eql ['"someone@example.com"']
    expect(mail.personalizations[0]['dynamic_template_data']).to eql one: '1'
  end

  it 'can add personalizations' do
    mail = DefaultsMailer.mail

    mail.add_personalization('one@example.com', dynamic_template_data: { one: '1' })
    mail.add_personalization('two@example.com', dynamic_template_data: { two: '2' })

    expect(mail.personalizations.length).to eql 2

    expect(mail.personalizations[0]['to']).to eql ['"one@example.com"']
    expect(mail.personalizations[0]['dynamic_template_data']).to eql one: '1'

    expect(mail.personalizations[1]['to']).to eql ['"two@example.com"']
    expect(mail.personalizations[1]['dynamic_template_data']).to eql two: '2'
  end
end
