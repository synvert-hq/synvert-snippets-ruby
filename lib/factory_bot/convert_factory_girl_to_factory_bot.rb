Synvert::Rewriter.new 'factory_bot', 'convert_factory_girl_to_factory_bot' do
  description <<-EOF
It converts factory_girl to factory_bot

  require 'factory_girl'
  require 'factory_girl_rails'
  =>
  require 'factory_bot'
  require 'factory_bot_rails'

  RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods
  end
  =>
  RSpec.configure do |config|
    config.include FactoryBot::Syntax::Methods
  end


  FactoryGirl.define do
    factory :user do
      email { Faker::Internet.email }
      username Faker::Name.first_name.downcase
      password "Sample:1"
      password_confirmation "Sample:1"
    end
  end
  =>
  FactoryBot.define do
    factory :user do
      email { Faker::Internet.email }
      username Faker::Name.first_name.downcase
      password "Sample:1"
      password_confirmation "Sample:1"
    end
  end

  user = FactoryGirl.create(:user)
  =>
  user = FactoryBot.create(:user)
  EOF

  within_files '{test,spec}/**/*.rb' do
    with_node type: 'const', to_source: 'FactoryGirl' do
      replace_with 'FactoryBot'
    end

    with_node type: 'send', receiver: nil, message: 'require', arguments: { first: 'factory_girl' } do
      replace_with "require 'factory_bot'"
    end
    with_node type: 'send', receiver: nil, message: 'require', arguments: { first: 'factory_girl_rails' } do
      replace_with "require 'factory_bot_rails'"
    end
  end
end