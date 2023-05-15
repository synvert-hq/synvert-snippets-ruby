# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_rails_test_request_methods_4_2_to_5_0' do
  description <<~EOS
    It converts rails test request methods from 4.2 to 5.0

    functional test:

    ```ruby
    get :show, { id: user.id, format: :json }, { admin: user.admin? }, { notice: 'Welcome' }
    ```

    =>

    ```ruby
    get :show, params: { id: user.id }, session: { admin: user.admin? }, flash: { notice: 'Welcome' }, as: :json
    ```

    integration test:

    ```ruby
    get '/posts/1', { user_id: user.id }, { 'HTTP_AUTHORIZATION' => 'fake' }
    ```

    =>

    ```ruby
    get '/posts/1', params: { user_id: user.id }, headers: { 'HTTP_AUTHORIZATION' => 'fake' }
    ```
  EOS

  if_gem 'rails', '>= 5.0'

  request_methods = %i[get post put patch delete]

  helper_method :make_up_hash_pair do |key, argument_node|
    next if argument_node.to_source == 'nil'

    if argument_node.type == :hash
      new_value =
        argument_node.children.reject { |pair_node|
          %i[format xhr as].include?(pair_node.key.to_value)
        }
                     .map(&:to_source).join(', ')
      "#{key}: #{add_curly_brackets_if_necessary(new_value)}" if new_value.length > 0
    else
      "#{key}: #{argument_node.to_source}"
    end
  end

  # get :show, { id: user.id }, { notice: 'Welcome' }, { admin: user.admin? }
  # =>
  # get :show, params: { id: user.id }, flash: { notice: 'Welcome' }, session: { admin: user.admin? }.
  within_files Synvert::RAILS_CONTROLLER_TEST_FILES do
    with_node type: 'send', message: { in: request_methods } do
      next unless node.arguments.size > 1
      next unless node.arguments[1].type == :hash
      next if node.arguments[1].key?(:params)

      format_value = node.arguments[1].format_value || node.arguments[1].as_value
      xhr_value = node.arguments[1].xhr_value
      options = []
      options << make_up_hash_pair('params', node.arguments[1])
      options << make_up_hash_pair('session', node.arguments[2]) if node.arguments.size > 2
      options << make_up_hash_pair('flash', node.arguments[3]) if node.arguments.size > 3
      options << "as: #{format_value.to_source}" if format_value
      options << "xhr: #{xhr_value.to_source}" if xhr_value
      replace :arguments, with: "{{arguments.first}}, #{options.compact.join(', ')}"
    end

    with_node type: 'send', message: 'xhr' do
      if node.arguments.size == 2
        replace :message, with: '{{arguments.first.to_string}}'
        replace :arguments, with: '{{arguments.1}}, xhr: true'
        next
      end
      format_value = node.arguments[2].type == :hash && node.arguments[2].format_value
      options = []
      options << make_up_hash_pair('params', node.arguments[2])
      options << make_up_hash_pair('session', node.arguments[3]) if node.arguments.size > 3
      options << make_up_hash_pair('flash', node.arguments[4]) if node.arguments.size > 4
      options << "as: #{format_value.to_source}" if format_value
      replace :message, with: '{{arguments.first.to_string}}'
      replace :arguments, with: "{{arguments.1}}, #{options.compact.join(', ')}, xhr: true"
    end
  end

  # get '/posts/1', user_id: user.id, { 'HTTP_AUTHORIZATION' => 'fake' }
  # =>
  # get '/posts/1', params: { user_id: user.id }, headers: { 'HTTP_AUTHORIZATION' => 'fake' }
  within_files Synvert::RAILS_INTEGRATION_TEST_FILES do
    with_node type: 'send', message: { in: request_methods } do
      next unless node.arguments.size > 1
      next if node.arguments[1].type == :hash && (node.arguments[1].key?(:params) || node.arguments[1].key?(:headers))

      options = []
      options << make_up_hash_pair('params', node.arguments[1])
      options << make_up_hash_pair('headers', node.arguments[2]) if node.arguments.size > 2
      replace :arguments, with: "{{arguments.first}}, #{options.compact.join(', ')}"
    end
  end
end
