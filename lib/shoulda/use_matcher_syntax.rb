# frozen_string_literal: true

Synvert::Rewriter.new 'shoulda', 'use_matcher_syntax' do
  description <<~EOF
    It converts shoulda macros to matcher syntax.
    
    models:
    
      should_belongs_to :user => should belong_to(:user)
    
      should_have_one :category => should have_one(:category)
    
      should_have_many :comments => should have_many(:comments)
    
      should_have_and_belong_to_many :tags => should have_and_belong_to_many(:tags)
    
      should_validate_presence_of :title, :body
      =>
      should validate_presence_of(:title)
      should validate_presence_of(:body)
    
      should_validate_uniqueness_of :name, :message => 'O NOES! SOMEONE STOELED YER NAME!'
      =>
      should validate_uniqueness_of(:name).with_message('O NOES! SOMEONE STOELED YER NAME!')
    
      should_validate_numericality_of :age => should validate_numericality_of(:age)
    
      should_validate_acceptance_of :eula => should validate_acceptance_of(:eula)
    
      should_ensure_length_in_range :password, (6..20)
      =>
      should ensure_length_of(:password).is_at_least(6).is_at_most(20)
    
      should_ensure_length_is :ssn, 9 => should ensure_length_of(:ssn).is_equal_to(9)
    
      should_ensure_value_in_range :age, (0..100)
      =>
      should ensure_inclusion_of(:age).in_range(0..100)
    
      should_allow_values_for :isbn, 'isbn 1 2345 6789 0', 'ISBN 1-2345-6789-0'
      =>
      should allow_value('isbn 1 2345 6789 0').for(:isbn)
      should allow_value('isbn 1-2345-6789-0').for(:isbn)
    
      should_not_allow_values_for :isbn, "bad1", "bad 2"
      =>
      should_not allow_value("bad1").for(:isbn)
      should_not allow_value("bad2").for(:isbn)
    
      should_allow_mass_assignment_of :first_name, :last_name
      =>
      should allow_mass_assignment_of(:first_name)
      should allow_mass_assignment_of(:last_name)
    
      should_not_allow_mass_assignment_of :password, :admin_flag
      =>
      should_not allow_mass_assignment_of(:password)
      should_not allow_mass_assignment_of(:admin_flag)
    
      should_have_readonly_attributes :password, :admin_flag
      =>
      should have_readonly_attributes(:password)
      should have_readonly_attributes(:admin_flag)
    
    controllers:
    
      should_set_the_flash_to "Thank you for placing this order."
      =>
      should set_the_flash.to("Thank you for placing this order.")
    
      should_not_set_the_flash => should_not set_the_flash
    
      should_filter_params :password, :ssn
      =>
      should filter_param(:password)
      should filter_param(:ssn)
    
      should_assign_to :user, :posts
      =>
      should assign_to(:user)
      should assign_to(:posts)
    
      should_assign_to :user, :class => User
      =>
      should assign_to(:user).with_kind_of(User)
    
      should_assign_to(:user) { @user } => should assign_to(:user).with(@user)
    
      should_not_assign_to :user, :posts
      =>
      should_not assign_to(:user)
      should_not assign_to(:posts)
    
      should_set_session(:user_id) { @user.id }
      =>
      should set_session(:user_id).to(@user.id)
    
      should_respond_with :success => should respond_with(:success)
    
      should_respond_with_content_type :rss => should respond_with_content_type(:rss)
    
      should_render_template :new => should render_template(:new)
    
      should_render_with_layout "special" => should render_with_layout("special")
    
      should_render_without_layout => should_not render_layout
    
      should_route :get, "/posts", :controller => :posts, :action => :index
      =>
      should route(:get, "/posts").to(:controller => :posts, :action => :index)
    
      should_redirect_to("the user profile") { user_url(@user) }
      =>
      should redirect_to("the user profile") { user_url(@user) }
  EOF

  if_gem 'shoulda', { gte: '2.11.0' }

  helper_method :hash_to_calls do |hash_node|
    new_calls = []
    message_converts = { message: 'with_message', short_message: 'with_short_message', long_message: 'with_long_message',
                        high_message: 'with_high_message', low_message: 'with_low_message' }
    hash_node.children.each do |pair_node|
      method = pair_node.key.to_value
      if method == :case_sensitive
        new_calls << (pair_node.value.to_value ? 'case_sensitive' : 'case_insensitive')
      else
        new_calls << "#{message_converts.has_key?(method) ? message_converts[method] : method}(#{pair_node.value.to_source})"
      end
    end
    new_calls.join('.')
  end

  helper_method :with_other_calls do |node, new_code|
    if node.arguments.last.type == :hash
      other_calls = hash_to_calls(node.arguments.last)
      replace_with "#{new_code}.#{other_calls}"
    else
      replace_with new_code
    end
  end

  unit_test_file_patterns = %w(test/unit/**/*_test.rb spec/models/**/*_spec.rb)
  functional_test_file_patterns = %w(test/functional/**/*_test.rb spec/controllers/**/*_spec.rb)

  unit_test_file_patterns.each do |file_pattern|
    within_files file_pattern do
      # should_have_many :comments
      # =>
      # should have_many(:comments)
      #
      # should_validate_presence_of :title
      # =>
      # should validate_presence_of(:title)
      #
      # should_allow_mass_assignment_of :first_name
      # =>
      # should allow_mass_assignment_of(:first_name)
      %w(should_belong_to should_have_one should_have_many should_have_and_belong_to_many
         should_validate_presence_of should_validate_uniqueness_of should_validate_numericality_of should_validate_acceptance_of
         should_allow_mass_assignment_of should_not_allow_mass_assignment_of
         should_have_readonly_attributes should_not_have_readonly_attributes).each do |message|
        with_node type: 'send', message: message do
          new_message = message.start_with?('should_not') ? message.sub('should_not_', 'should_not ') : message.sub('_', ' ')
          if node.arguments.size == 1
            replace_with "#{new_message}({{arguments}})"
          elsif node.arguments.last.type == :hash
            other_calls = hash_to_calls(node.arguments.last)
            replace_with "#{new_message}({{arguments.first}}).#{other_calls}"
          else
            replaced_code = []
            node.arguments.each do |argument|
              replaced_code << "#{new_message}(#{argument.to_source})"
            end
            replace_with replaced_code.join("\n")
          end
        end
      end

      # should_ensure_length_in_range :password, (6..20)
      # =>
      # should ensure_length_of(:password).is_at_least(6).is_at_most(20)
      with_node type: 'send', message: 'should_ensure_length_in_range' do
        range = strip_brackets(node.arguments[1].to_source).split('..')
        with_other_calls(node, "should ensure_length_of({{arguments.first}}).is_at_least(#{range.first}).is_at_most(#{range.last})")
      end

      # should_ensure_length_at_least :name, 3
      # =>
      # should ensure_length_of(:name).is_at_least(3)
      with_node type: 'send', message: 'should_ensure_length_at_least' do
        with_other_calls(node, 'should ensure_length_of({{arguments.first}}).is_at_least({{arguments[1]}})')
      end

      # should_ensure_length_at_most :name, 30
      # =>
      # should ensure_length_of(:name).is_at_most(30)
      with_node type: 'send', message: 'should_ensure_length_at_most' do
        with_other_calls(node, 'should ensure_length_of({{arguments.first}}).is_at_most({{arguments[1]}})')
      end

      # should_ensure_length_is :ssn, 9
      # =>
      # should ensure_length_of(:ssn).is_equal_to(9)
      with_node type: 'send', message: 'should_ensure_length_is' do
        with_other_calls(node, 'should ensure_length_of({{arguments.first}}).is_equal_to({{arguments[1]}})')
      end

      # should_ensure_value_in_range :age, (0..100)
      # =>
      # should ensure_inclusion_of(:age).in_range(0..100)
      with_node type: 'send', message: 'should_ensure_value_in_range' do
        range = strip_brackets(node.arguments[1].to_source)
        with_other_calls(node, "should ensure_inclusion_of({{arguments.first}}).in_range(#{range})")
      end

      # should_allow_values_for :isbn, 'isbn 1 2345 6789 0', 'ISBN 1-2345-6789-0'
      # =>
      # should allow_value('isbn 1 2345 6789 0').for(:isbn)
      # should allow_value('ISBN 1-2345-6789-0').for(:isbn)
      %w(should_allow_values_for should_not_allow_values_for).each do |message|
        with_node type: 'send', message: message do
          should_or_should_not = message.include?('_not') ? 'should_not' : 'should'
          field = node.arguments.first.to_source
          replace_with node.arguments[1..-1].map { |node_argument|
            "#{should_or_should_not} allow_value(#{node_argument.to_source}).for(#{field})"
          }.join("\n")
        end
      end
    end
  end

  functional_test_file_patterns.each do |file_pattern|
    within_files file_pattern do
      # should_assign_to(:user) { @user } => should assign_to(:user).with(@user)
      with_node type: 'block', caller: { type: 'send', message: 'should_assign_to' } do
        replace_with 'should assign_to({{caller.arguments}}).with({{body}})'
      end

      # should_set_session(:user_id) { @user.id }
      # =>
      # should set_session(:user_id).to(@user.id)
      with_node type: 'block', caller: { type: 'send', message: 'should_set_session' } do
        replace_with 'should set_session({{caller.arguments}}).to({{body}})'
      end

      # should_redirect_to("the user profile") { user_url(@user) }
      # =>
      # should redirect_to("the user profile") { user_url(@user) }
      with_node type: 'block', caller: { type: 'send', message: 'should_redirect_to' } do
        replace_with 'should redirect_to({{caller.arguments}}) { {{body}} }'
      end
    end
  end

  functional_test_file_patterns.each do |file_pattern|
    within_files file_pattern do
      # should_set_the_flash_to "Thank you for placing this order."
      # =>
      # should set_the_flash.to("Thank you for placing this order.")
      with_node type: 'send', message: 'should_set_the_flash_to' do
        replace_with 'should set_the_flash.to({{arguments}})'
      end

      # should_not_set_the_flash => should_not set_the_flash
      with_node type: 'send', message: 'should_not_set_the_flash' do
        replace_with 'should_not set_the_flash'
      end

      # should_filter_params :password, :ssn
      # =>
      # should filter_param(:password)
      # should filter_param(:ssn)
      with_node type: 'send', message: 'should_filter_params' do
        replace_with node.arguments.map { |node_argument|
          "should filter_param(#{node_argument.to_source})"
        }.join("\n")
      end

      # should_assign_to :user, :posts
      # =>
      # should assign_to(:user)
      # should assign_to(:posts)
      #
      # should_assign_to :user, :class => User
      # =>
      # should assign_to(:user).with_kind_of(User)
      with_node type: 'send', message: 'should_assign_to' do
        if node.arguments.last.type == :hash
          klazz = node.arguments.last.values.first
          replace_with "should assign_to({{arguments.first}}).with_kind_of(#{klazz.to_source})"
        else
          replace_with node.arguments.map { |node_argument|
            "should assign_to(#{node_argument.to_source})"
          }.join("\n")
        end
      end

      # should_not_assign_to :user, :posts
      # =>
      # should_not assign_to(:user)
      # should_not assign_to(:posts)
      with_node type: 'send', message: 'should_not_assign_to' do
        replace_with node.arguments.map { |node_argument|
          "should_not assign_to(#{node_argument.to_source})"
        }.join("\n")
      end

      # should_respond_with :success => should respond_with(:success)
      #
      # should_respond_with_content_type :rss => should respond_with_content_type(:rss)
      #
      # should_render_template :new => should render_template(:new)
      #
      # should_render_with_layout "special" => should render_with_layout("special")
      %w(should_respond_with should_respond_with_content_type should_render_template should_render_with_layout).each do |message|
        with_node type: 'send', message: message do
          new_message = message.sub('_', ' ')
          replace_with "#{new_message}({{arguments}})"
        end
      end

      # should_render_without_layout => should_not render_layout
      with_node type: 'send', message: 'should_render_without_layout' do
        replace_with 'should_not render_with_layout'
      end

      # should_route :get, "/posts", :controller => :posts, :action => :index
      # =>
      # should route(:get, "/posts").to(:controller => :posts, :action => :index)
      with_node type: 'send', message: 'should_route' do
        replace_with 'should route({{arguments.first}}, {{arguments[1]}}).to({{arguments.last}})'
      end
    end
  end
end
