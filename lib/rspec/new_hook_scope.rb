# frozen_string_literal: true

Synvert::Rewriter.new 'rspec', 'new_hook_scope' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It converts new hook scope.

    ```ruby
    before(:each) { do_something }
    before(:all) { do_something }
    ```

    =>

    ```ruby
    before(:example) { do_something }
    before(:context) { do_something }
    ```
  EOS

  if_gem 'rspec-core', '>= 3.0'

  within_files Synvert::RAILS_RSPEC_FILES do
    # before(:each) { do_something }
    # =>
    # before(:example) { do_something }
    #
    # before(:all) { do_something }
    # =>
    # before(:context) { do_something }
    %w[before after around].each do |scope|
      with_node type: 'send', message: scope, arguments: [:all] do
        replace :arguments, with: ':context'
      end

      with_node type: 'send', message: scope, arguments: [:each] do
        replace :arguments, with: ':example'
      end
    end
  end
end
