# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'frozen_string_literal_comment' do
  configure(parser: Synvert::SYNTAX_TREE_PARSER)

  description <<~EOS
    It adds frozen_string_literal: true comment.

    ```ruby
    'hello world'
    ```

    =>

    ```ruby
    # frozen_string_literal: true

    'hello world'
    ```
  EOS

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    find_node ":not_has(> .Comment[value='# frozen_string_literal: true'])" do
      insert "# frozen_string_literal: true\n\n", at: 'beginning'
    end
  end
end
