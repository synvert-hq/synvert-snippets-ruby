# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'prefer-endless-method' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It prefers endless method.

    ```ruby
    def one_plus_one
      1 + 1
    end
    ```

    =>

    ```ruby
    def one_plus_one = 1 + 1
    ```
  EOS

  if_ruby '3.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    find_node '.def_node[body!=nil][body.body.length=1]' do
      new_body = dedent(node.body.to_source)
      replace_with "def {{name}}{{lparen}}{{parameters}}{{rparen}} = #{new_body}"
    end
  end
end
