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
    ```

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
    ```
  EOS

  # prepend include FactoryBot::Syntax::Methods
  within_file 'spec/spec_helper.rb' do
    find_node '.block[caller=.send[receiver=RSpec][message=configure]]
                :not_has(.send[message=include][arguments.size=1][arguments.first=FactoryBot::Syntax::Methods])' do
      prepend '{{arguments.first}}.include FactoryBot::Syntax::Methods'
    end
  end

  # prepend include FactoryBot::Syntax::Methods
  within_file 'test/test_helper.rb' do
    find_node '.class[name IN (Test::Unit::TestCase ActiveSupport::TestCase MiniTest::Unit::TestCase MiniTest::Spec MiniTest::Rails::ActiveSupport::TestCase)]
                :not_has(.send[message=include][arguments.size=1][arguments.first=FactoryBot::Syntax::Methods])' do
      prepend 'include FactoryBot::Syntax::Methods'
    end
  end

  # prepend World(FactoryBot::Syntax::Methods)
  within_file 'features/support/env.rb' do
    find_node ':not_has(.send[message=World][arguments.size=1][arguments.first=FactoryBot::Syntax::Methods])' do
      insert_after 'World(FactoryBot::Syntax::Methods)'
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
  within_files Synvert::RAILS_TEST_FILES do
    find_node '.send[receiver=FactoryBot][message IN (create build attributes_for build_stubbed create_list build_list create_pair build_pair)]' do
      delete :receiver, :dot
    end
  end
end
