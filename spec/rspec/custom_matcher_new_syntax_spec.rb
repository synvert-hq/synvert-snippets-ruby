require 'spec_helper'

describe 'Use RSpec custom matcher new syntax' do
  let!(:rewriter_path) { File.join(File.dirname(__FILE__), '../../lib/rspec/custom_matcher_new_syntax.rb') }
  let!(:rewriter) { eval(File.read(rewriter_path)) }

  describe 'with fakefs', fakefs: true do
    let(:post_spec_content) {"
RSpec::Matchers.define :be_awesome do
  match_for_should { }
  match_for_should_not { }
  failure_message_for_should { }
  failure_message_for_should_not { }
end
    "}
    let(:post_spec_rewritten_content) {"
RSpec::Matchers.define :be_awesome do
  match { }
  match_when_negated { }
  failure_message { }
  failure_message_when_negated { }
end
    "}

    it 'converts' do
      FileUtils.mkdir_p 'spec/models'
      File.write 'spec/models/post_spec.rb', post_spec_content
      rewriter.process
      expect(File.read 'spec/models/post_spec.rb').to eq post_spec_rewritten_content
    end
  end
end
