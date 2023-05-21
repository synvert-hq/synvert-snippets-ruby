# frozen_string_literal: true

Synvert::Rewriter.new 'factory_girl', 'use_short_syntax' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    Uses FactoryGirl short syntax.

    1. it adds FactoryGirl::Syntax::Methods module to RSpec, Test::Unit, Cucumber, Spainach, MiniTest, MiniTest::Spec, minitest-rails.

    ```ruby
    # rspec
    RSpec.configure do |config|
      config.include FactoryGirl::Syntax::Methods
    end

    # Test::Unit
    class Test::Unit::TestCase
      include FactoryGirl::Syntax::Methods
    end

    # Cucumber
    World(FactoryGirl::Syntax::Methods)

    # Spinach
    class Spinach::FeatureSteps
      include FactoryGirl::Syntax::Methods
    end

    # MiniTest
    class MiniTest::Unit::TestCase
      include FactoryGirl::Syntax::Methods
    end

    # MiniTest::Spec
    class MiniTest::Spec
      include FactoryGirl::Syntax::Methods
    end

    # minitest-rails
    class MiniTest::Rails::ActiveSupport::TestCase
      include FactoryGirl::Syntax::Methods
    end
    ```

    2. it converts to short syntax.

    ```ruby
    FactoryGirl.create(...)
    FactoryGirl.build(...)
    FactoryGirl.attributes_for(...)
    FactoryGirl.build_stubbed(...)
    FactoryGirl.create_list(...)
    FactoryGirl.build_list(...)
    FactoryGirl.create_pair(...)
    FactoryGirl.build_pair(...)
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

  if_gem 'factory_girl', '>= 2.0'

  # prepend include FactoryGirl::Syntax::Methods
  within_file 'spec/spec_helper.rb' do
    find_node '.block[caller=.send[receiver=RSpec][message=configure]]
                :not_has(.send[message=include][arguments=(FactoryGirl::Syntax::Methods)])' do
      prepend '{{arguments.first}}.include FactoryGirl::Syntax::Methods'
    end
  end

  # prepend include FactoryGirl::Syntax::Methods
  within_file 'test/test_helper.rb' do
    find_node '.class[name IN (Test::Unit::TestCase ActiveSupport::TestCase MiniTest::Unit::TestCase MiniTest::Spec MiniTest::Rails::ActiveSupport::TestCase)]
                :not_has(.send[message=include][arguments=(FactoryGirl::Syntax::Methods)])' do
      prepend 'include FactoryGirl::Syntax::Methods'
    end
  end

  # prepend World(FactoryGirl::Syntax::Methods)
  within_file 'features/support/env.rb' do
    find_node ':not_has(.send[message=World][arguments=(FactoryGirl::Syntax::Methods)])' do
      insert_after 'World(FactoryGirl::Syntax::Methods)'
    end
  end

  # FactoryGirl.create(...) => create(...)
  # FactoryGirl.build(...) => build(...)
  # FactoryGirl.attributes_for(...) => attributes_for(...)
  # FactoryGirl.build_stubbed(...) => build_stubbed(...)
  # FactoryGirl.create_list(...) => create_list(...)
  # FactoryGirl.build_list(...) => build_list(...)
  # FactoryGirl.create_pair(...) => create_pair(...)
  # FactoryGirl.build_pair(...) => build_pair(...)
  within_files Synvert::RAILS_TEST_FILES do
    find_node '.send[receiver=FactoryGirl][message IN (create build attributes_for build_stubbed create_list build_list create_pair build_pair)]' do
      delete :receiver, :dot
    end
  end
end
