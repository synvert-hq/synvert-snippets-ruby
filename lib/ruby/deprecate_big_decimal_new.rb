# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'deprecate_big_decimal_new' do
  description <<~EOS
    It converts BigDecimal.new to BigDecimal

    ```ruby
    BigDecimal.new('1.1')
    ```

    =>

    ```ruby
    BigDecimal('1.1')
    ```
  EOS

  within_files '**/*.rb' do
    with_node type: 'send', receiver: 'BigDecimal', message: 'new' do
      replace_with 'BigDecimal({{arguments}})'
    end
  end
end
