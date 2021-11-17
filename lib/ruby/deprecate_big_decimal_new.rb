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

  within_files Synvert::ALL_RUBY_FILES do
    with_node type: 'send', receiver: 'BigDecimal', message: 'new' do
      delete :dot, :message
    end
  end
end
