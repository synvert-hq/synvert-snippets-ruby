# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'hooks_super' do
  description <<~EOS
    If using a module containing `setup` or `teardown` methods, be sure to call `super` in the test class `setup` or `teardown`.

    ```ruby
    class TestMeme < Minitest::Test
      include MyHelper

      def setup
        do_something
      end

      def teardown
        clean_something
      end
    end
    ```

    =>

    ```ruby
    class TestMeme < Minitest::Test
      include MyHelper

      def setup
        super
        do_something
      end

      def teardown
        clean_something
        super
      end
    end
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    with_node type: 'class', parent_class: 'Minitest::Test' do
      with_node type: 'def', name: 'setup' do
        unless_exist_node type: 'super' do
          prepend 'super'
        end
      end

      with_node type: 'def', name: 'teardown' do
        unless_exist_node type: 'super' do
          append 'super'
        end
      end
    end
  end
end
