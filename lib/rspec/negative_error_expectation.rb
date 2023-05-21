# frozen_string_literal: true

Synvert::Rewriter.new 'rspec', 'negative_error_expectation' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It converts rspec negative error expectation.

    ```ruby
    expect { do_something }.not_to raise_error(SomeErrorClass)
    expect { do_something }.not_to raise_error('message')
    expect { do_something }.not_to raise_error(SomeErrorClass, 'message')
    ```

    =>

    ```ruby
    expect { do_something }.not_to raise_error
    expect { do_something }.not_to raise_error
    expect { do_something }.not_to raise_error
    ```
  EOS
  if_gem 'rspec-core', '>= 2.14'

  within_files Synvert::RAILS_RSPEC_FILES do
    # expect { do_something }.not_to raise_error(SomeErrorClass) => expect { do_something }.not_to raise_error
    # expect { do_something }.not_to raise_error('message') => expect { do_something }.not_to raise_error
    # expect { do_something }.not_to raise_error(SomeErrorClass, 'message') => expect { do_something }.not_to raise_error
    within_node type: 'send', receiver: { type: 'block' }, message: 'not_to' do
      with_node type: 'send', message: 'raise_error', arguments: { size: { gt: 0 } } do
        replace_with 'raise_error'
      end
    end
  end
end
