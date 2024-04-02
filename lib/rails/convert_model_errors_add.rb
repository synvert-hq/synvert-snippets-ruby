# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_model_errors_add' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts to activerecord `errors.add`.

    ```ruby
    errors[:base] = "author not present"
    self.errors[:base] = "author not present"
    ```

    =>

    ```ruby
    errors.add(:base, "author not present")
    self.errors.add(:base, "author not present")
    ```
  EOS

  if_gem 'activerecord', '>= 5.0'

  within_files Synvert::RAILS_MODEL_FILES do
    with_node node_type: 'call_node',
              receiver: { node_type: 'call_node', name: 'errors', arguments: nil },
              name: '[]=',
              arguments: { node_type: 'arguments_node', arguments: { size: 2 } } do
      replace_with '{{receiver}}.add({{arguments.arguments.0}}, {{arguments.arguments.1}})'
    end
  end
end
