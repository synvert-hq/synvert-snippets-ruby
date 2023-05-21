# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'deprecate_big_decimal_new' do
  configure(parser: Synvert::PARSER_PARSER)

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
    find_node '.send[receiver=BigDecimal][message=new]' do
      delete :dot, :message
    end
  end
end
