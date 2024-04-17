# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_rails_logger' do
  configure(parser: Synvert::PRISM_PARSER)

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

  if_gem 'rails', '>= 2.3'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    with_node node_type: 'constant_read_node', name: 'RAILS_DEFAULT_LOGGER' do
      replace_with 'Rails.logger'
    end
  end
end
