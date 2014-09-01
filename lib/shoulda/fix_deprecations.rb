Synvert::Rewriter.new 'shoulda', 'fix_deprecations' do
  description <<-EOF
It converts deprecations

After version 1.5.0

models:

  should validate_format_of(:email).with('user@example.com')
  =>
  should allow_value('user@example.com').for(:email)

controllers:

  should assign_to(:user)
  =>
  should "assigns user" do
    assert_not_nil assigns(:user)
  end

  should assign_to(:user) { @user }
  =>
  should "assigns user" do
    assert_equal @user, assigns(:user)
  end

  should respond_with_content_type "application/json"
  =>
  should "responds with application/json" do
    assert_equal "application/json", response.content_type
  end

After version 2.6.2

  should ensure_inclusion_of(:age).in_range(0..100)
  =>
  should validate_inclusion_of(:age).in_range(0..100)

  should ensure_exclusion_of(:age).in_range(0..100)
  =>
  should validate_exclusion_of(:age).in_range(0..100)
  EOF

  if_gem 'shoulda-matchers', {gte: '1.5.0'}

  UNIT_TESTS_FILE_PATTERNS = %w(test/unit/**/*_test.rb spec/models/**/*_spec.rb)
  FUNCTIONAL_TESTS_FILE_PATTERNS = %w(test/functional/**/*_test.rb spec/controllers/**/*_spec.rb)

  UNIT_TESTS_FILE_PATTERNS.each do |file_pattern|
    within_files file_pattern do
      # should validate_format_of(:email).with('user@example.com')
      # =>
      # should allow_value('user@example.com').for(:email)
      with_node type: 'send', message: 'should', arguments: {first: {
        type: 'send', receiver: {type: 'send', message: 'validate_format_of'}, message: 'with'}} do
          value = node.arguments.first.arguments.first.to_source
          field = node.arguments.first.receiver.arguments.first.to_source
          replace_with "should allow_value(#{value}).for(#{field})"
      end
    end
  end

  FUNCTIONAL_TESTS_FILE_PATTERNS.each do |file_pattern|
    within_files file_pattern do
      # should assign_to(:user)
      # =>
      # should "assigns user" do
      #   assert_not_nil assigns(:user)
      # end
      with_node type: 'send', message: 'should', arguments: {first: {type: 'send', message: 'assign_to'}} do
        assign_to_param = node.arguments.first.arguments.first.to_value
        replace_with """should \"assigns #{assign_to_param}\" do
  assert_not_nil assigns(:#{assign_to_param})
end"""
      end

      # should_not assign_to(:user)
      # =>
      # should "no assigns user" do
      #   assert_nil assigns(:user)
      # end
      with_node type: 'send', message: 'should_not', arguments: {first: {type: 'send', message: 'assign_to'}} do
        assign_to_param = node.arguments.first.arguments.first.to_value
        replace_with """should \"no assigns #{assign_to_param}\" do
  assert_nil assigns(:#{assign_to_param})
end"""
      end

      # should assign_to(:user) { @user }
      # =>
      # should "assigns user" do
      #   assert_equal @user, assigns(:user)
      # end
      with_node type: 'send', message: 'should', arguments: {first: {type: 'block', caller: {type: 'send', message: 'assign_to'}}} do
        assign_to_param = node.arguments.first.caller.arguments.first.to_value
        assign_to_value = node.arguments.first.body.first.to_source
        replace_with """should \"assigns #{assign_to_param}\" do
  assert_equal #{assign_to_value}, assigns(:#{assign_to_param})
end"""
      end

      # should_not assign_to(:user) { @user }
      # =>
      # should "no assigns user" do
      #   assert_not_equal @user, assigns(:user)
      # end
      with_node type: 'send', message: 'should_not', arguments: {first: {type: 'block', caller: {type: 'send', message: 'assign_to'}}} do
        assign_to_param = node.arguments.first.caller.arguments.first.to_value
        assign_to_value = node.arguments.first.body.first.to_source
        replace_with """should \"no assigns #{assign_to_param}\" do
  assert_not_equal #{assign_to_value}, assigns(:#{assign_to_param})
end"""
      end

      # should respond_with_content_type "application/json"
      # =>
      # should "responds with application/json" do
      #   assert_equal "application/json", response.content_type
      # end
      within_node type: 'send', message: 'should', arguments: {first: {type: 'send', message: 'respond_with_content_type'}} do
        content_type = node.arguments.first.arguments.first.to_value
        replace_with """should \"responds with #{content_type}\" do
  assert_equal \"#{content_type}\", response.content_type
end"""
      end
    end
  end

  if_gem 'shoulda-matchers', {gt: '2.6.2'}

  UNIT_TESTS_FILE_PATTERNS.each do |file_pattern|
    within_files file_pattern do
      # should ensure_inclusion_of(:age).in_range(0..100)
      # =>
      # should validate_inclusion_of(:age).in_range(0..100)
      with_node type: 'send', message: 'ensure_inclusion_of' do
        replace_with "validate_inclusion_of({{arguments}})"
      end

      # should ensure_exclusion_of(:age).in_range(0..100)
      # =>
      # should validate_exclusion_of(:age).in_range(0..100)
      with_node type: 'send', message: 'ensure_exclusion_of' do
        replace_with "validate_exclusion_of({{arguments}})"
      end
    end
  end
end
