# frozen_string_literal: true

Synvert::Rewriter.new 'rspec', 'remove_monkey_patches' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It removes monkey patching of the top level methods like describe

    ```ruby
    RSpec.configure do |rspec|
    end
    ```

    =>

    ```ruby
    RSpec.configure do |rspec|
      rspec.expose_dsl_globally = false
    end
    ```

    ```ruby
    describe 'top-level example group' do
      describe 'nested example group' do
      end
    end
    ```

    =>

    ```ruby
    RSpec.describe 'top-level example group' do
      describe 'nested example group' do
      end
    end
    ```
  EOS

  if_gem 'rspec-core', '>= 3.0'

  monkey_patches_methods = %w[describe shared_examples shared_examples_for shared_context]

  within_files Synvert::RAILS_RSPEC_FILES do
    # describe 'top-level example group' do
    #   describe 'nested example group' do
    #   end
    # end
    # =>
    # RSpec.describe 'top-level example group' do
    #   describe 'nested example group' do
    #   end
    # end
    with_node(
      { node_type: 'block', caller: { node_type: 'send', receiver: nil, message: { in: monkey_patches_methods } } },
      { recursive: false }
    ) do
      insert 'RSpec.', at: 'beginning'
    end
  end

  within_file 'spec/spec_helper.rb' do
    # RSpec.configure do |rspec|
    # end
    # =>
    # RSpec.configure do |rspec|
    #   rspec.expose_dsl_globally = false
    # end
    within_node node_type: 'block', caller: { node_type: 'send', receiver: 'RSpec', message: 'configure' } do
      unless_exist_node node_type: 'send', message: 'expose_dsl_globally=' do
        append '{{arguments}}.expose_dsl_globally = false'
      end
    end
  end
end
