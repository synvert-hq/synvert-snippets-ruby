# encoding: utf-8

require 'spec_helper'

describe 'Convert rails mailers from 2.3 to 3.0' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/convert_mailers_2_3_to_3_0.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:notifier_content) {'
class Notifier < ActionMailer::Base
  def signup_notification(recipient)
    recipients      recipient.email_address_with_name
    subject         "New account information"
    from            "system@example.com"
    sent_on         Time.now
    content_type    "multipart/alternative"
    body            :account => recipient
  end
end
    '}
    let(:notifier_rewritten_content) {'
class Notifier < ActionMailer::Base
  def signup_notification(recipient)
    @account = recipient
    mail(:to => recipient.email_address_with_name, :subject => "New account information", :from => "system@example.com", :date => Time.now)
  end
end
    '}
    let(:notifiers_content) {'
class NotifiersController < ApplicationController
  def notify
    Notifier.deliver_signup_notification(recipient)

    message = Notifier.create_signup_notification(recipient)
    Notifier.deliver(message)
  end
end
    '}
    let(:notifiers_rewritten_content) {'
class NotifiersController < ApplicationController
  def notify
    Notifier.signup_notification(recipient).deliver

    message = Notifier.signup_notification(recipient)
    message.deliver
  end
end
    '}

    it 'converts' do
      FileUtils.mkdir_p 'app/models'
      FileUtils.mkdir_p 'app/controllers'
      File.write 'app/models/notifier.rb', notifier_content
      File.write 'app/controllers/notifiers_controller.rb', notifiers_content
      @rewriter.process
      expect(File.read 'app/models/notifier.rb').to eq notifier_rewritten_content
      expect(File.read 'app/controllers/notifiers_controller.rb').to eq notifiers_rewritten_content
    end
  end
end
