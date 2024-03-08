# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'deprecate_big_decimal_new' do
  configure(parser: Synvert::PRISM_PARSER)

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

  if_ruby '2.6.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    find_node ".call_node[receiver=BigDecimal][name=new][arguments=.arguments_node[arguments.size=1]]" do
      delete :message, :call_operator
    end
  end
end
