# frozen_string_literal: true

Synvert::Rewriter.new 'factory_bot', 'use_short_syntax' do
  description <<~EOS
    Uses FactoryBot short syntax.

    1. it adds FactoryBot::Syntax::Methods module to RSpec, Test::Unit, Cucumber, Spainach, MiniTest, MiniTest::Spec, minitest-rails.

    ```ruby
    # rspec
    RSpec.configure do |config|
      config.include FactoryBot::Syntax::Methods
    end

    # Test::Unit
    class Test::Unit::TestCase
      include FactoryBot::Syntax::Methods
    end

    # Cucumber
    World(FactoryBot::Syntax::Methods)

    # Spinach
    class Spinach::FeatureSteps
      include FactoryBot::Syntax::Methods
    end

    # MiniTest
    class MiniTest::Unit::TestCase
      include FactoryBot::Syntax::Methods
    end

    # MiniTest::Spec
    class MiniTest::Spec
      include FactoryBot::Syntax::Methods
    end

    # minitest-rails
    class MiniTest::Rails::ActiveSupport::TestCase
      include FactoryBot::Syntax::Methods
    end
    ```

    2. it converts to short syntax.

    ```ruby
    FactoryBot.create(...)
    FactoryBot.build(...)
    FactoryBot.attributes_for(...)
    FactoryBot.build_stubbed(...)
    FactoryBot.create_list(...)
    FactoryBot.build_list(...)
    FactoryBot.create_pair(...)
    FactoryBot.build_pair(...)
    ```ruby

    =>

    ```ruby
    create(...)
    build(...)
    attributes_for(...)
    build_stubbed(...)
    create_list(...)
    build_list(...)
    create_pair(...)
    build_pair(...)
    ```ruby
  EOS

  # insert include FactoryBot::Syntax::Methods
  within_file 'spec/spec_helper.rb' do
    within_node type: 'block', caller: { receiver: 'RSpec', message: 'configure' } do
      unless_exist_node type: 'send', message: 'include', arguments: ['FactoryBot::Syntax::Methods'] do
        insert '{{arguments.first}}.include FactoryBot::Syntax::Methods'
      end
    end
  end

  # insert include FactoryBot::Syntax::Methods
  within_file 'test/test_helper.rb' do
    %w[Test::Unit::TestCase ActiveSupport::TestCase MiniTest::Unit::TestCase MiniTest::Spec MiniTest::Rails::ActiveSupport::TestCase].each do |class_name|
      within_node type: 'class', name: class_name do
        unless_exist_node type: 'send', message: 'include', arguments: ['FactoryBot::Syntax::Methods'] do
          insert 'include FactoryBot::Syntax::Methods'
        end
      end
    end
  end

  # insert World(FactoryBot::Syntax::Methods)
  within_file 'features/support/env.rb' do
    unless_exist_node type: 'send', message: 'World', arguments: ['FactoryBot::Syntax::Methods'] do
      insert 'World(FactoryBot::Syntax::Methods)'
    end
  end

  # FactoryBot.create(...) => create(...)
  # FactoryBot.build(...) => build(...)
  # FactoryBot.attributes_for(...) => attributes_for(...)
  # FactoryBot.build_stubbed(...) => build_stubbed(...)
  # FactoryBot.create_list(...) => create_list(...)
  # FactoryBot.build_list(...) => build_list(...)
  # FactoryBot.create_pair(...) => create_pair(...)
  # FactoryBot.build_pair(...) => build_pair(...)
  within_files '{test,spec,features}/**/*.rb' do
    %w[create build attributes_for build_stubbed create_list build_list create_pair build_pair].each do |message|
      with_node type: 'send', receiver: 'FactoryBot', message: message do
        replace_with "#{message}({{arguments}})"
      end
    end
  end
end
