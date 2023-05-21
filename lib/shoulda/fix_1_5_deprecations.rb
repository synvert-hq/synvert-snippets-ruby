# frozen_string_literal: true

Synvert::Rewriter.new 'shoulda', 'fix_1_5_deprecations' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It fixes shoulda 1.5 deprecations.

    models:

    ```ruby
    should validate_format_of(:email).with('user@example.com')
    ```

    =>

    ```ruby
    should allow_value('user@example.com').for(:email)
    ```

    controllers:

    ```ruby
    should assign_to(:user)

    should assign_to(:user) { @user }

    should respond_with_content_type "application/json"
    ```

    =>

    ```ruby
    should "assigns user" do
      assert_not_nil assigns(:user)
    end

    should "assigns user" do
      assert_equal @user, assigns(:user)
    end

    should "responds with application/json" do
      assert_equal "application/json", response.content_type
    end
    ```
  EOS

  if_gem 'shoulda-matchers', '>= 1.5'

  within_files Synvert::RAILS_MODEL_TEST_FILES do
    # should validate_format_of(:email).with('user@example.com')
    # =>
    # should allow_value('user@example.com').for(:email)
    find_node '.send[message=should][arguments.size=1]
                    [arguments.first=.send[message=with][receiver=.send[message=validate_format_of][arguments.size=1]]]' do
      replace_with "should allow_value({{arguments.first.arguments.first}}).for({{arguments.first.receiver.arguments.first}})"
    end
  end

  within_files Synvert::RAILS_CONTROLLER_TEST_FILES do
    # should assign_to(:user)
    # =>
    # should "assigns user" do
    #   assert_not_nil assigns(:user)
    # end
    find_node '.send[message=should][arguments.size=1] [arguments.first=.send[message=assign_to][arguments.size=1]]' do
      replace_with <<~EOS
        should 'assigns {{arguments.first.arguments.first.to_value}}' do
          assert_not_nil assigns({{arguments.first.arguments.first}})
        end
      EOS
    end

    # should_not assign_to(:user)
    # =>
    # should "no assigns user" do
    #   assert_nil assigns(:user)
    # end
    find_node '.send[message=should_not][arguments.size=1]
                    [arguments.first=.send[message=assign_to][arguments.size=1]]' do
      replace_with <<~EOS
        should 'no assigns {{arguments.first.arguments.first.to_value}}' do
          assert_nil assigns({{arguments.first.arguments.first}})
        end
      EOS
    end

    # should assign_to(:user) { @user }
    # =>
    # should "assigns user" do
    #   assert_equal @user, assigns(:user)
    # end
    find_node '.send[message=should][arguments.size=1]
                    [arguments.first=.block[caller=.send[message=assign_to][arguments.size=1]]]' do
      replace_with <<~EOS
        should 'assigns {{arguments.first.caller.arguments.first.to_value}}' do
          assert_equal {{arguments.first.body.first}}, assigns({{arguments.first.caller.arguments.first}})
        end
      EOS
    end

    # should_not assign_to(:user) { @user }
    # =>
    # should "no assigns user" do
    #   assert_not_equal @user, assigns(:user)
    # end
    find_node '.send[message=should_not][arguments.size=1]
                    [arguments.first=.block[caller=.send[message=assign_to][arguments.size=1]]]' do
      replace_with <<~EOS
        should 'no assigns {{arguments.first.caller.arguments.first.to_value}}' do
          assert_not_equal {{arguments.first.body.first}}, assigns({{arguments.first.caller.arguments.first}})
        end
      EOS
    end

    # should respond_with_content_type "application/json"
    # =>
    # should "responds with application/json" do
    #   assert_equal "application/json", response.content_type
    # end
    find_node '.send[message=should][arguments.size=1]
                    [arguments.first=.send[message=respond_with_content_type][arguments.size=1]]' do
      replace_with <<~EOS
        should 'responds with {{arguments.first.arguments.first.to_value}}' do
          assert_equal {{arguments.first.arguments.first}}, response.content_type
        end
      EOS
    end
  end
end
