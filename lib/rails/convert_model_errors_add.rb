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

  if_gem 'activerecord', { gte: '5.0.0' }

  within_files 'app/models/**/*.rb' do
    # errors[] =
    # =>
    # errors.add
    with_node type: 'send', receiver: 'errors', message: '[]=' do
      replace_with 'errors.add({{arguments.first}}, {{arguments.last}})'
    end

    # self.errors[] =
    # =>
    # self.errors.add
    with_node type: 'send', receiver: { type: 'send', message: 'errors' }, message: '[]=' do
      replace_with '{{receiver}}.add({{arguments.first}}, {{arguments.last}})'
    end
  end
end
