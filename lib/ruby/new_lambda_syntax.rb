# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'new_lambda_syntax' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    Use ruby new lambda syntax

    ```ruby
    lambda { test }
    lambda { |a, b, c| a + b + c }
    ```

    =>

    ```ruby
    -> { test }
    ->(a, b, c) { a + b + c }
    ```
  EOS

  if_ruby '1.9.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # lambda { test } => -> { test }
    find_node '.call_node[receiver=nil][name=lambda][block=.block_node][parameters=nil]' do
      replace_with '-> { {{block.body}} }'
    end

    # lambda { |a, b, c| a + b + c } => ->(a, b, c) { a + b + c }
    find_node '.call_node[receiver=nil][name=lambda][block=.block_node[parameters=.block_parameters_node]]' do
      replace_with '->({{block.parameters.parameters}}) { {{block.body}} }'
    end
  end
end
