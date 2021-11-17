# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'define_class_from_classic_mode_to_zeitwerk_mode' do
  description <<~EOS
    It converts class defination from classic mode to zeitwerk mode.

    ```ruby
    class Foo::Bar < Base
      def test; end
    end
    ```

    =>

    ```ruby
    module Foo
      class Bar < Base
        def test; end
      end
    end
    ```
  EOS

  redo_until_no_change

  original_names = []

  # round one
  within_files Synvert::ALL_RUBY_FILES do
    # class Foo::Bar < Base
    #   def test; end
    # end
    # =>
    # module Foo
    #   class Foo::Bar < Base
    #     def test; end
    #   end
    # end
    within_node type: 'class' do
      original_name = node.name.to_source
      if original_name.include?('::') && !original_names.include?(original_name)
        original_names << original_name
        module_name, = original_name.split('::', 2)
        wrap with: "module #{module_name}"
      end
    end
  end

  # round two
  within_files Synvert::ALL_RUBY_FILES do
    # class Foo:Bar < Base
    # end
    # =>
    # class Bar < Base
    # end
    within_node type: 'class', name: { in: original_names } do
      original_name = node.name.to_source
      _, class_name = original_name.split('::', 2)
      replace :name, with: class_name
    end
  end
end
