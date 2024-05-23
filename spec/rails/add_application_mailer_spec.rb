# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Add ApplicationMailer' do
  let(:rewriter_name) { 'rails/add_application_mailer' }

  context 'add application_job' do
    let(:fake_file_path) { 'app/mailers/application_mailer.rb' }
    let(:test_content) { nil }
    let(:test_rewritten_content) { <<~EOS }
      class ApplicationMailer < ActionMailer::Base
      end
    EOS

    include_examples 'convertable'
  end

  context 'rename ActionMailer::Base' do
    let(:fake_file_path) { 'app/mailers/post_mailer.rb' }
    let(:test_content) { <<~EOS }
      class PostMailer < ActionMailer::Base
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      class PostMailer < ApplicationMailer
      end
    EOS

    include_examples 'convertable'
  end
end
