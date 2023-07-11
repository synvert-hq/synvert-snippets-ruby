# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'prefer_nor_conditions' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    Prefer NOR conditions

    ```ruby
    where.not(first_name: nil, last_name: nil)
    ```

    =>

    ```ruby
    where.not(first_name: nil).where.not(last_name: nil)
    ```
  EOS

  if_gem 'rails', '>= 6.0'

  within_files Synvert::ALL_RUBY_FILES do
    find_node '.send[receiver=.send[message=where][arguments.size=0]][message=not][arguments.size=1][arguments.0=.hash[pairs.length>1]]' do
      new_source = node.arguments[0].pairs.map { |pair| "where.not(#{pair.to_source})" }
                       .join('.')
      replace 'receiver.message', :message, :parentheses, with: new_source
    end
  end
end
