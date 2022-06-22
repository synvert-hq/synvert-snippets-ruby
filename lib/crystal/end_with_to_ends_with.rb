# .../lib/crystal/_template.rb
# frozen_string_literal: true

Synvert::Rewriter.new("crystal", "#{File.basename(__FILE__).split('.')[0]}") do
  description <<~EOS
    It converts `String#end_with?` to `String#ends_with?`

    ```ruby
    a_string.end_with?(param)
    ```

    =>

    ```ruby
    a_string.ends_with?(param)
    ```
  EOS

  within_files "**/*.rb" do
    # a_string.end_with?(param)
    # =>
    # a_string.ends_with?(param)
    with_node type:     "send",
              receiver: {
                type: "send",
                message: "end_with?",
                arguments: {
                  size: 1
                }
              } do
      replace :receiver, with: "{{receiver.receiver}}"
      replace :message, with: "ends_with?"
    end
  end
end
