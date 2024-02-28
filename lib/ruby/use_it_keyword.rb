# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'use_it_keyword' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It uses it keyword.

    ```ruby
    (1...10).map { |num| num ** 2 }
    (1...10).map { _1 ** 2 }
    ```

    =>

    ```ruby
    (1...10).map { it ** 2 }
    (1...10).map { it ** 2 }
    ```
  EOS

  if_ruby '3.4'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    find_node '.call_node[block=.block_node[parameters=.block_parameters_node[parameters=.parameters_node[requireds.size=1]]]]' do
      group do
        find_node ".local_variable_read_node[name=#{node.block.parameters.parameters.requireds[0].name}]" do
          replace_with 'it'
        end
        delete 'block.parameters'
      end
    end

    find_node '.call_node[block=.block_node[parameters=.numbered_parameters_node[maximum=1]]] .local_variable_read_node[name=_1]' do
      replace_with 'it'
    end
  end
end
