# frozen_string_literal: true

Synvert::Rewriter.new 'factory_bot', 'convert_factory_girl_to_factory_bot' do
  description <<~EOS
    It converts FactoryGirl to FactoryBot

    ```ruby
    require 'factory_girl'
    require 'factory_girl_rails'
    ```

    =>

    ```ruby
    require 'factory_bot'
    require 'factory_bot_rails'
    ```

    ```ruby
    RSpec.configure do |config|
      config.include FactoryGirl::Syntax::Methods
    end
    ```

    =>

    ```ruby
    RSpec.configure do |config|
      config.include FactoryBot::Syntax::Methods
    end
    ```

    ```ruby
    FactoryGirl.define do
      factory :user do
        email { Faker::Internet.email }
        username Faker::Name.first_name.downcase
        password "Sample:1"
        password_confirmation "Sample:1"
      end
    end
    ```

    =>

    ```ruby
    FactoryBot.define do
      factory :user do
        email { Faker::Internet.email }
        username Faker::Name.first_name.downcase
        password "Sample:1"
        password_confirmation "Sample:1"
      end
    end
    ```

    ```ruby
    FactoryGirl.create(:user)
    FactoryGirl.build(:user)
    ```

    =>

    ```ruby
    FactoryBot.create(:user)
    FactoryBot.build(:user)
    ```
  EOS

  within_files Synvert::RAILS_TEST_FILES do
    find_node '.const[name=FactoryGirl]' do
      replace_with 'FactoryBot'
    end

    find_node ".send[receiver=nil][message=require][arguments.size=1][arguments.first='factory_girl']" do
      replace :arguments, with: "'factory_bot'"
    end
    find_node ".send[receiver=nil][message=require][arguments.size=1][arguments.first='factory_girl_rails']" do
      replace :arguments, with: "'factory_bot_rails'"
    end
  end
end
