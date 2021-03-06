# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_rails_test_request_methods_4_2_to_5_0' do
  description <<~EOS
    It converts rails test request methods from 4.2 to 5.0

    functional test:

    ```ruby
    get :show, { id: user.id }, { notice: 'Welcome' }, { admin: user.admin? }
    ```

    =>

    ```ruby
    get :show, params: { id: user.id }, flash: { notice: 'Welcome' }, session: { admin: user.admin? }.
    ```

    integration test:

    ```ruby
    get '/posts/1', user_id: user.id, { 'HTTP_AUTHORIZATION' => 'fake' }
    ```

    =>

    ```ruby
    get '/posts/1', params: { user_id: user.id }, headers: { 'HTTP_AUTHORIZATION' => 'fake' }
    ```
  EOS

  helper_method :make_up_hash_pair do |key, argument_node|
    if argument_node.to_source != 'nil'
      if argument_node.type == :hash
        "#{key}: #{add_curly_brackets_if_necessary(argument_node.to_source)}"
      else
        "#{key}: #{argument_node.to_source}"
      end
    end
  end

  # get :show, { id: user.id }, { notice: 'Welcome' }, { admin: user.admin? }
  # =>
  # get :show, params: { id: user.id }, flash: { notice: 'Welcome' }, session: { admin: user.admin? }.
  within_files '{test,spec}/{functional,controllers}/**/*.rb' do
    %w[get post put patch delete].each do |message|
      with_node type: 'send', message: message do
        next unless node.arguments.size > 1
        next unless node.arguments[1].type == :hash
        next if node.arguments[1].has_key?(:params)

        options = []
        options << make_up_hash_pair('params', node.arguments[1])
        options << make_up_hash_pair('flash', node.arguments[2]) if node.arguments.size > 2
        options << make_up_hash_pair('session', node.arguments[3]) if node.arguments.size > 3
        replace_with "#{message} {{arguments.first}}, #{options.compact.join(', ')}"
      end
    end
  end

  # get '/posts/1', user_id: user.id, { 'HTTP_AUTHORIZATION' => 'fake' }
  # =>
  # get '/posts/1', params: { user_id: user.id }, headers: { 'HTTP_AUTHORIZATION' => 'fake' }
  within_files '{test,spec}/{integration}/**/*.rb' do
    %w[get post put patch delete].each do |message|
      with_node type: 'send', message: message do
        next unless node.arguments.size > 1
        if node.arguments[1].type == :hash &&
             (node.arguments[1].has_key?(:params) || node.arguments[1].has_key?(:headers))
          next
        end

        options = []
        options << make_up_hash_pair('params', node.arguments[1])
        options << make_up_hash_pair('headers', node.arguments[2]) if node.arguments.size > 2
        replace_with "#{message} {{arguments.first}}, #{options.compact.join(', ')}"
      end
    end
  end
end
