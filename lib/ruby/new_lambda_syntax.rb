# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'new_lambda_syntax' do
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

  within_files Synvert::ALL_RUBY_FILES do
    # lambda { test } => -> { test }
    find_node '.block[caller=.send[receiver=nil][message=lambda]][arguments.size=0]' do
      replace_with '-> { {{body}} }'
    end

    # lambda { |a, b, c| a + b + c } => ->(a, b, c) { a + b + c }
    find_node '.block[caller=.send[receiver=nil][message=lambda]][arguments.size > 0]' do
      replace_with '->({{arguments}}) { {{body}} }'
    end
  end
end
