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
      first_body_node = node.body.body.first
      if %i[if_node unless_node].include?(first_body_node.type) && first_body_node.end_keyword.nil?
        break
      end
      break if first_body_node.type == :multi_write_node
      body_column = mutation_adapter.get_start_loc(first_body_node).column
      new_body = node.body.body.first.to_source.split("\n").map { |line| line.sub(/^ {#{body_column}}/, '') }.join("\n")
      replace_with "def {{name}}{{lparen}}{{parameters}}{{rparen}} = #{new_body}"
    end
  end
end
