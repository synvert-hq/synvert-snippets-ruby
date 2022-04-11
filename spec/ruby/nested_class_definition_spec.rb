# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'nested class definition' do
  let(:rewriter_name) { 'ruby/nested_class_definition' }

  context 'single module' do
    let(:test_content) { <<~EOS }
      class Foo::Bar < Base
        def test; end
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      module Foo
        class Bar < Base
          def test; end
        end
      end
    EOS

    include_examples 'convertable'
  end

  context 'nested modules' do
    let(:test_content) { <<~EOS }
      class Foo::Bar::FooBar < Base
        def test; end
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      module Foo
        module Bar
          class FooBar < Base
            def test; end
          end
        end
      end
    EOS

    include_examples 'convertable'
  end
end
