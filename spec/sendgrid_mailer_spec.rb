RSpec.describe SendGridMailer do
  class TestMailer < SendGridMailer
    default template_id: 'template-id'
    default from: 'notifications@example.com', from_name: 'Example Notifier'
    default subject: 'Hello from example'
  end

  describe 'setting attributes' do
    it 'sets email fields from provided defaults' do
      mailer = TestMailer.mailer

      expect(mailer).not_to be nil

      expect(mailer.template_id).to eql 'template-id'
      expect(mailer.from).to eql 'notifications@example.com'
      expect(mailer.from_name).to eql 'Example Notifier'
      expect(mailer.subject).to eql 'Hello from example'
    end

    it 'can override defaults through mailer' do
      mailer = TestMailer.mailer template_id: 'new-template-id',
                                 from: 'two@example.com',
                                 from_name: 'Two',
                                 subject: 'Subject Two'

      expect(mailer.template_id).to eql 'new-template-id'
      expect(mailer.from).to eql 'two@example.com'
      expect(mailer.from_name).to eql 'Two'
      expect(mailer.subject).to eql 'Subject Two'
    end

    it 'can override just the email' do
      mailer = TestMailer.mailer(from: 'two@example.com')

      expect(mailer.from).to eql 'two@example.com'

      expect(mailer.template_id).to eql 'template-id'
      expect(mailer.from_name).to eql 'Example Notifier'
      expect(mailer.subject).to eql 'Hello from example'
    end

    it 'can override just the name' do
      mailer = TestMailer.mailer(from_name: 'Me Two')

      expect(mailer.from_name).to eql 'Me Two'

      expect(mailer.template_id).to eql 'template-id'
      expect(mailer.from).to eql 'notifications@example.com'
      expect(mailer.subject).to eql 'Hello from example'
    end

    it 'adds personalization if to email is provided' do
      mailer = TestMailer.mailer(to: 'someone@example.com', dynamic_template_data: { one: '1' })

      expect(mailer.personalizations.length).to eql 1

      expect(mailer.personalizations[0]['to']).to eql ['email' => 'someone@example.com']
      expect(mailer.personalizations[0]['dynamic_template_data']).to eql one: '1'
    end

    it 'can add multiple to emails using mailer' do
      mailer = TestMailer.mailer to: ['one@example.com',
                                      { email: 'two@example.com', name: 'User Two' },
                                      'three@example.com']

      expect(mailer.personalizations.length).to eql 1

      expect(mailer.personalizations[0]['to']).to eql [
        { 'email' => 'one@example.com' },
        { 'email' => 'two@example.com', 'name' => 'User Two' },
        { 'email' => 'three@example.com' }
      ]
    end

    it 'can add personalizations' do
      mailer = TestMailer.mailer

      mailer.add_personalization 'one@example.com',
                                 dynamic_template_data: { one: '1' },
                                 substitutions: {
                                   '-name-' => 'Some Name',
                                   '-age-' => '18'
                                 }

      mailer.add_personalization 'two@example.com', dynamic_template_data: { two: '2' }

      expect(mailer.personalizations.length).to eql 2

      expect(mailer.personalizations[0]['to']).to eql ['email' => 'one@example.com']
      expect(mailer.personalizations[0]['dynamic_template_data']).to eql one: '1'
      expect(mailer.personalizations[0]['substitutions']).to eql '-name-' => 'Some Name',
                                                                 '-age-' => '18'

      expect(mailer.personalizations[1]['to']).to eql ['email' => 'two@example.com']
      expect(mailer.personalizations[1]['dynamic_template_data']).to eql two: '2'
    end

    it 'can add multiple to emails using personalizations' do
      mailer = TestMailer.mailer

      mailer.add_personalization ['one@example.com',
                                  { email: 'two@example.com', name: 'User Two' },
                                  'three@example.com'],
                                 dynamic_template_data: { one: '1' }

      expect(mailer.personalizations.length).to eql 1

      expect(mailer.personalizations[0]['to']).to eql [
        { 'email' => 'one@example.com' },
        { 'email' => 'two@example.com', 'name' => 'User Two' },
        { 'email' => 'three@example.com' }
      ]
    end

    it 'can add categories' do
      mailer = TestMailer.mailer categories: %w[one two three]

      expect(mailer.categories).to eql %w[one two three]
    end

    it 'can add custom args' do
      mailer = TestMailer.mailer custom_args: { 'one' => 'two', 'foo' => 'bar' }

      expect(mailer.custom_args).to eql 'one' => 'two', 'foo' => 'bar'
    end

    describe 'content' do
      it 'does not add content by default' do
        mailer = TestMailer.mailer

        expect(mailer.contents).to be_empty
      end

      it 'allows adding html content through mailer call' do
        mailer = TestMailer.mailer content_html: '<html><body>My html content</body></html>'

        expect(mailer.contents).to eql [
          { 'type' => 'text/html', 'value' => '<html><body>My html content</body></html>' }
        ]
      end

      it 'allows adding html content through add_html_content method' do
        mailer = TestMailer.mailer

        mailer.add_html_content '<html><body>My html content</body></html>'

        expect(mailer.contents).to eql [
          { 'type' => 'text/html', 'value' => '<html><body>My html content</body></html>' }
        ]
      end

      it 'allows adding text content through mailer call' do
        mailer = TestMailer.mailer content_text: 'My text content'

        expect(mailer.contents).to eql [
          { 'type' => 'text/plain', 'value' => 'My text content' }
        ]
      end

      it 'allows adding html content through add_html_content method' do
        mailer = TestMailer.mailer

        mailer.add_text_content 'My text content'

        expect(mailer.contents).to eql [
          { 'type' => 'text/plain', 'value' => 'My text content' }
        ]
      end
    end

    describe 'tracking' do
      describe 'click tracking' do
        it 'does not set click tracking by default' do
          mailer = TestMailer.mailer

          expect(mailer.tracking_settings.click_tracking).to be nil
        end

        it 'can enable click tracking through method' do
          mailer = TestMailer.mailer

          mailer.click_tracking true, enable_text: 'something'

          expect(mailer.tracking_settings.click_tracking).to eql 'enable' => true,
                                                                 'enable_text' => 'something'
        end

        it 'can disable click tracking through method' do
          mailer = TestMailer.mailer

          mailer.click_tracking false

          expect(mailer.tracking_settings.click_tracking).to eql 'enable' => false
        end

        it 'can enable click tracking through mailer' do
          mailer = TestMailer.mailer(click_tracking: true)

          expect(mailer.tracking_settings.click_tracking).to eql 'enable' => true
        end

        it 'can disable click tracking through mailer' do
          mailer = TestMailer.mailer(click_tracking: false)

          expect(mailer.tracking_settings.click_tracking).to eql 'enable' => false
        end
      end

      describe 'open tracking' do
        it 'does not set open tracking by default' do
          mailer = TestMailer.mailer

          expect(mailer.tracking_settings.open_tracking).to be nil
        end

        it 'can enable open tracking through method' do
          mailer = TestMailer.mailer

          mailer.open_tracking true, substitution_tag: 'something'

          expect(mailer.tracking_settings.open_tracking).to eql 'enable' => true,
                                                                'substitution_tag' => 'something'
        end

        it 'can disable open tracking through method' do
          mailer = TestMailer.mailer

          mailer.open_tracking false

          expect(mailer.tracking_settings.open_tracking).to eql 'enable' => false
        end

        it 'can enable open tracking through mailer' do
          mailer = TestMailer.mailer(open_tracking: true)

          expect(mailer.tracking_settings.open_tracking).to eql 'enable' => true
        end

        it 'can disable open tracking through mailer' do
          mailer = TestMailer.mailer(open_tracking: false)

          expect(mailer.tracking_settings.open_tracking).to eql 'enable' => false
        end
      end
    end
  end

  describe '#deliver' do
    let(:sendgrid_api_key) { 'sendgrid-api-key' }
    let(:sendgrid_response_status) { 202 }
    let(:sendgrid_response_body) { '' }

    let(:mailer) { TestMailer.mailer }

    before do
      SendGridMailer.disable_mock!

      stub_request(:post, 'https://api.sendgrid.com/v3/mail/send')
        .with(
          body: mailer.sg_mail.to_json,
          headers: {
            'Accept' => 'application/json',
            'Authorization' => 'Bearer sendgrid-api-key',
            'Content-Type' => 'application/json'
          }
        )
        .to_return(status: sendgrid_response_status, body: sendgrid_response_body)
    end

    after { SendGridMailer.enable_mock! }

    context 'when an api key is not provided' do
      it 'raises a configuration error' do
        expect { mailer.deliver }.to raise_error SendGridMailer::ConfigurationError
      end
    end

    context 'when an api key is provided' do
      before { SendGridMailer.config.api_key = sendgrid_api_key }
      after { SendGridMailer.config.api_key = nil }

      context 'when the delivery is successful' do
        let(:sendgrid_response_status) { 202 }

        it 'does not raise any errors' do
          expect { puts mailer.deliver }.not_to raise_error
        end
      end

      context 'when the delivery is not successful' do
        let(:sendgrid_response_status) { 400 }
        let(:sendgrid_response_body) { { error: 'something happened' }.to_json }

        it 'raises an error with the response body' do
          expect { mailer.deliver }.to raise_error SendGridMailer::DeliveryError
        end
      end
    end
  end
end
