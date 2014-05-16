require 'securerandom'

Synvert::Rewriter.new "upgrade_rails_4_0_to_4_1" do
  description <<-EOF
It upgrades rails from 4.0 to 4.1.

1. config/secrets.yml
    Create a secrets.yml file in your config folder
    Copy the existing secret_key_base from the secret_token.rb initializer to secrets.yml under the production section.
    Remove the secret_token.rb initializer

2. remove ActiveRecord::Migration.check_pending! in test/test_helper.rb
    add `require 'test_help'`

3. add config/initializers/cookies_serializer.rb

4. replace MultiJson.dump with obj.to_json
    MultiJson.load with JSON.parse(str)

5. warn return within inline callback blocks
    before_save { return false }
  EOF

  secrets_content = <<-EOF
development:
  secret_key_base: #{SecureRandom.hex(64)}

test:
  secret_key_base: #{SecureRandom.hex(64)}

# Do not keep production secrets in the repository,
# instead read values from the environment.
production:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  EOF
  add_file 'config/secrets.yml', secrets_content.strip

  remove_file 'config/initializers/secret_token.rb'

  within_file 'test/test_helper.rb' do
    # ActiveRecord::Migration.check_pending! => require 'test_help'
    with_node type: 'send', receiver: 'ActiveRecord::Migration', message: 'check_pending!' do
      replace_with "require 'test_help'"
    end
  end

  add_file 'config/initializers/cookies_serializer.rb', 'Rails.application.config.action_dispatch.cookies_serializer = :json'

  within_files '**/*.rb' do
    # MultiJson.dump(obj) => obj.to_json
    with_node type: 'send', receiver: 'MultiJson', message: 'dump' do
      replace_with "{{arguments}}.to_json"
    end

    # MultiJson.load(str) => JSON.parse(str)
    with_node type: 'send', receiver: 'MultiJson', message: 'load' do
      replace_with "JSON.parse {{arguments}}"
    end
  end

  within_files '**/*.rb' do
    [/before_/, /after_/].each do |message_regex|
      # Warn if finding return in before_* or after_* callbacks
      within_node type: 'block', caller: {type: 'send', message: message_regex} do
        with_node type: 'return' do
          warn 'Using a return statement in an inline callback block causes a LocalJumpError to be raised when the callback is executed.'
        end
      end
    end
  end
end
