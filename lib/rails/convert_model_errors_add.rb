# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_model_errors_add' do
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
    with_node node_type: 'send', receiver: { node_type: 'send', message: 'errors', arguments: { size: 0 } }, message: '[]=', arguments: { size: 2 } do
      replace_with '{{receiver}}.add({{arguments.0}}, {{arguments.1}})'
    end
  end
end
