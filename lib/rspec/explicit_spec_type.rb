# frozen_string_literal: true

Synvert::Rewriter.new 'rspec', 'explicit_spec_type' do
  description <<~EOS
    It explicits spec type.

    ```ruby
    RSpec.configure do |rspec|
    end
    ```

    =>

    ```ruby
    RSpec.configure do |rspec|
      rspec.infer_spec_type_from_file_location!
    end
    ```

    ```ruby
    describe SomeModel do
    end
    ```

    =>

    ```ruby
    describe SomeModel, :type => :model do
    end
    ```
  EOS

  if_gem 'rspec-rails', '>= 2.99'

  within_file 'spec/rails_helper.rb' do
    # RSpec.configure do |rspec|
    # end
    # =>
    # RSpec.configure do |rspec|
    #   rspec.infer_spec_type_from_file_location!
    # end
    within_node type: 'block', caller: { type: 'send', receiver: 'RSpec', message: 'configure' } do
      unless_exist_node type: 'send', message: 'infer_spec_type_from_file_location!' do
        append '{{arguments}}.infer_spec_type_from_file_location!'
      end
    end
  end

  # describe SomeModel do
  # end
  # =>
  # describe SomeModel, type: :model do
  # end
  {
    models: 'model',
    controllers: 'controller',
    helpers: 'helper',
    mailers: 'mailer',
    requests: 'request',
    integration: 'request',
    api: 'request',
    routing: 'routing',
    views: 'view',
    services: 'service',
    features: 'feature'
  }.each do |directory, type|
    within_files ["spec/#{directory}/**/*_spec.rb", "engines/*/spec/#{directory}/**/*_spec.rb"] do
      with_node({ type: 'block', caller: { type: 'send', message: 'describe' } }, { stop_at_first_match: true }) do
        goto_node :caller do
          unless_exist_node type: 'pair', key: :type do
            insert ", type: :#{type}"
          end
        end
      end
    end
  end
end
