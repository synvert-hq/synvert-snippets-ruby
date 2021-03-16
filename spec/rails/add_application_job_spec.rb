# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Add ApplicationJob' do
  let(:rewriter_name) { 'rails/add_application_job' }

  context 'add application_job' do
    let(:fake_file_path) { 'app/jobs/application_job.rb' }
    let(:test_content) { nil }
    let(:test_rewritten_content) { <<~EOS }
        class ApplicationJob < ActiveJob::Base
        end
    EOS

    include_examples 'convertable'
  end

  context 'rename ActiveJob::Base' do
    let(:fake_file_path) { 'app/jobs/post_job.rb' }
    let(:test_content) { <<~EOS }
        class PostJob < ActiveJob::Base
        end
    EOS
    let(:test_rewritten_content) { <<~EOS }
        class PostJob < ApplicationJob
        end
    EOS

    include_examples 'convertable'
  end
end
