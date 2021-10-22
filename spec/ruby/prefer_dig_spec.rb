# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Prefer dig' do
  let(:rewriter_name) { 'ruby/prefer_dig' }
  let(:fake_file_path) { 'foobar.rb' }
  let(:test_content) { <<~EOS }
    def action
      params[:foo] && params[:foo][:bar]

      params[one] && params[one][two] && params[one][two][three]

      params[one] && params[one][two] && params[one][two][three] && params[one][two][three][four]
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    def action
      params.dig(:foo, :bar)

      params.dig(one, two, three)

      params.dig(one, two, three, four)
    end
  EOS

  include_examples 'convertable'
end
