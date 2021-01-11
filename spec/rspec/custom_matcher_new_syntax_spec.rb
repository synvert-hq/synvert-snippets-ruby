require 'spec_helper'

RSpec.describe 'Use RSpec custom matcher new syntax' do
  let(:rewriter_name) { 'rspec/custom_matcher_new_syntax' }
  let(:fake_file_path) { 'spec/models/post_spec.rb' }
  let(:test_content) { "
RSpec::Matchers.define :be_awesome do
  match_for_should { }
  match_for_should_not { }
  failure_message_for_should { }
  failure_message_for_should_not { }
end
  "}
  let(:test_rewritten_content) { "
RSpec::Matchers.define :be_awesome do
  match { }
  match_when_negated { }
  failure_message { }
  failure_message_when_negated { }
end
  "}

  include_examples 'convertable'
end
