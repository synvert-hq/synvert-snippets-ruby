# .../spec/crystal/_template.rb
# frozen_string_literal: true

# an example spec template ...

require 'spec_helper'

RSpec.describe 'Crystal .end_with? to .ends_with?' do
  let(:rewriter_name) { 'crystal/end_with_to_ends_with' }
  let(:test_content) { <<~EOS }
    def something(a_string)
      a_string.end_with?(param)
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    def something(a_string)
      a_string.ends_with?(param)
    end
  EOS

  include_examples 'convertable'
end
