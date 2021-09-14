# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'numbered parameters' do
  description <<~EOS
    It uses numbered parameters.

    ```ruby
    squared_numbers = (1...10).map { |num| num ** 2 }

    city_populations.each { |city, population| puts "Population of \#{city} is \#{population}" }
    ```

    =>

    ```ruby
    squared_numbers = (1...10).map { _1 ** 2 }

    city_populations.each { puts "Population of \#{_1} is \#{_2}" }
    ```
  EOS

  if_ruby '2.7'

  within_files '**/*.rb' do
    within_node type: 'block', arguments: { length: { not: 0 } } do
      node.arguments.each_with_index do |argument, index|
        with_node type: 'lvar', name: argument.name do
          replace_with "_#{index + 1}"
        end
      end
      delete :arguments, :pipes
    end
  end
end
