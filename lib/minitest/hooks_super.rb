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
    find_node '.class[parent_class=Minitest::Test] .def[name=setup]:not_has(> .super)' do
      prepend 'super'
    end

    find_node '.class[parent_class=Minitest::Test] .def[name=teardown]:not_has(> .super)' do
      append 'super'
    end
  end
end
