# frozen_string_literal: true

Synvert::Rewriter.new 'rspec', 'stub_and_mock_to_double' do
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

  within_files 'spec/**/*.rb' do
    # stub('something') => double('something')
    # mock('something') => double('something')
    with_node type: 'send', receiver: nil, message: 'stub' do
      replace :message, with: 'double'
    end

    with_node type: 'send', receiver: nil, message: 'mock' do
      replace :message, with: 'double'
    end
  end
end
