# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'use_it_keyword' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It uses it keyword.

    ```ruby
    squared_numbers = (1...10).map { |num| num ** 2 }
    squared_numbers = (1...10).map { _1 ** 2 }
    ```

    =>

    ```ruby
    squared_numbers = (1...10).map { it ** 2 }
    squared_numbers = (1...10).map { it ** 2 }
    ```
  EOS

  if_ruby '3.3'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    find_node '.block[arguments.size=1]' do
      group do
        find_node ".lvar[name=#{node.arguments[0].name}]" do
          replace_with 'it'
        end
        delete :arguments, :pipes
      end
    end

    find_node '.numblock[arguments_count=1] .lvar[name=_1]' do
      replace_with 'it'
    end
  end
end
