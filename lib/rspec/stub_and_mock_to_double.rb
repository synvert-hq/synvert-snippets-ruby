# frozen_string_literal: true

Synvert::Rewriter.new 'rspec', 'stub_and_mock_to_double' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It converts stub and mock to double.

    ```ruby
    stub('something')
    mock('something')
    ```

    =>

    ```ruby
    double('something')
    double('something')
    ```
  EOS

  if_gem 'rspec-core', '>= 2.14'

  within_files Synvert::RAILS_RSPEC_FILES do
    # stub('something') => double('something')
    # mock('something') => double('something')
    with_node node_type: 'send', receiver: nil, message: { in: ['stub', 'mock'] } do
      replace :message, with: 'double'
    end
  end
end
