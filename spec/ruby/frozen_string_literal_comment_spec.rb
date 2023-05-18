# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Ruby adds frozen_string_literal: true' do
  context 'frozen_string_literal: true does not exist' do
    let(:rewriter_name) { 'ruby/frozen_string_literal_comment' }
    let(:test_content) { "'hello world'" }
    let(:test_rewritten_content) { "# frozen_string_literal: true\n\n'hello world'" }

    include_examples 'convertable'
  end

  context 'frozen_string_literal: true exists' do
    let(:rewriter_name) { 'ruby/frozen_string_literal_comment' }
    let(:test_content) { "# frozen_string_literal: true\n\n'hello world'" }
    let(:test_rewritten_content) { "# frozen_string_literal: true\n\n'hello world'" }

    include_examples 'convertable'
  end
end
