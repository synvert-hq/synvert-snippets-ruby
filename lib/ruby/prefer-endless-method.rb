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
      break if node.name.to_s.end_with?('=')
      break if !node.parameters.nil? && node.lparen.nil? && node.rparen.nil?

      first_body_node = node.body.body.first
      break if %i[if_node unless_node].include?(first_body_node.type) && first_body_node.end_keyword.nil?
      break if %i[multi_write_node instance_variable_or_write_node class_variable_or_write_node or_node and_node hash_node].include?(first_body_node.type)
      break if first_body_node.type == :call_node && first_body_node.opening.nil? && !first_body_node.arguments.nil? && first_body_node.closing.nil? && !first_body_node.block.nil?

      body_column = mutation_adapter.get_start_loc(first_body_node).column
      new_body = first_body_node.to_source.split("\n").map { |line| line.sub(/^ {#{body_column}}/, '') }.join("\n")
      receiver_and_name = node.receiver ? "#{node.receiver.to_source}.#{node.name}" : node.name.to_s
      replace_with "def #{receiver_and_name}{{lparen}}{{parameters}}{{rparen}} = #{new_body}"
    end
  end
end
