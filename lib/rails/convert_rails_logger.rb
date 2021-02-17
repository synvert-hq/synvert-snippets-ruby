# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_rails_logger' do
  description <<~EOS
  It converts RAILS_DEFAULT_LOGGER to Rails.logger.

  ```ruby
  RAILS_DEFAULT_LOGGER
  ```

  =>

  ```ruby
  Rails.logger
  ```
  EOS

  if_gem 'rails', { gte: '2.3.0' }

  within_files '**/*.{rb,rake}' do
    with_node type: 'const', to_source: 'RAILS_DEFAULT_LOGGER' do
      replace_with 'Rails.logger'
    end
    with_node type: 'const', to_source: '::RAILS_DEFAULT_LOGGER' do
      replace_with 'Rails.logger'
    end
  end
end
