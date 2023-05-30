# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_routes_2_3_to_3_0' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It converts rails routes from 2.3 to 3.0.

    ```ruby
    map.root :controller => "home", :action => :index
    ```

    =>

    ```ruby
    root :to => "home#index"
    ```

    ```ruby
    map.connect "/:controller/:action/:id"
    ```

    =>

    ```ruby
    match "/:controller(/:action(/:id))(.:format)"
    ```

    ```ruby
    map.admin_signup "/admin_signup", :controller => "admin_signup", :action => "new", :method => "post"
    ```

    =>

    ```ruby
    post "/admin_signup", :to => "admin_signup#new", :as => "admin_signup"
    ```

    ```ruby
    map.with_options :controller => "manage" do |manage|
      manage.manage_index "manage_index", :action => "index"
      manage.manage_intro "manage_intro", :action => "intro"
    end
    ```

    =>

    ```ruby
    manage.manage_index "manage_index", :to => "index#manage"
    manage.manage_intro "manage_intro", :to => "intro#manage"
    ```

    ```ruby
    map.namespace :admin do |admin|
      admin.resources :users
    end
    ```

    =>

    ```ruby
    namespace :admin do
      resources :users
    end
    ```

    ```ruby
    map.resources :posts, :collection => { :generate_pdf => :get }, :member => {:activate => :post} do |posts|
      posts.resources :comments
    end
    ```

    =>

    ```ruby
    resources :posts do
      collection do
        get :generate_pdf
      end
      member do
        post :activate
      end
      resources :comments
    end
    ```
  EOS

  if_gem 'rails', '>= 2.3'

  helper_method :extract_controller_action_name do |hash_node|
    controller_name = hash_node.controller_value.to_value
    action_name = hash_node.action_value.to_value
    "#{controller_name}##{action_name}"
  end

  helper_method :extract_subdomain_node do |hash_node|
    if hash_node.key?(:conditions) && hash_node.conditions_value.key?(:subdomain)
      hash_node.conditions_value.subdomain_value
    end
  end

  helper_method :extract_method do |hash_node|
    method = hash_node.method_value.to_value if hash_node.key?(:method)
    if !method && hash_node.key?(:conditions) && hash_node.conditions_value.key?(:method)
      method = hash_node.conditions_value.method_value.to_value
    end
    method || 'match'
  end

  helper_method :generate_new_member_routes do |member_routes|
    new_member_routes = []
    new_member_routes << "  member do\n"
    if member_routes.type == :hash
      member_routes.children.each do |pair_node|
        Array(pair_node.value.to_value).each do |method|
          method = 'match' if method == :any
          new_member_routes << "    #{method} :#{pair_node.key.to_value}\n"
        end
      end
    else
      Array(member_routes.to_value).each do |method|
        new_member_routes << "    match :#{method}\n"
      end
    end
    new_member_routes << "  end\n"
    new_member_routes.join
  end

  helper_method :generate_new_collection_routes do |collection_routes|
    new_collection_routes = []
    new_collection_routes << "  collection do\n"
    if collection_routes.type == :hash
      collection_routes.children.each do |pair_node|
        Array(pair_node.value.to_value).each do |method|
          method = 'match' if method == :any
          new_collection_routes << "    #{method} :#{pair_node.key.to_value}\n"
        end
      end
    else
      Array(collection_routes.to_value).each do |method|
        new_collection_routes << "    match :#{method}\n"
      end
    end
    new_collection_routes << "  end\n"
    new_collection_routes.join
  end

  helper_method :generate_new_child_routes do |parent_node, parent_argument|
    parent_node.body.map { |child_node| "  #{child_node.to_source.sub(parent_argument, 'map')}\n" }
               .join('')
  end

  within_file Synvert::RAILS_ROUTE_FILES do
    # map.namespace :admin do |admin|
    #   admin.resources :users
    # end
    # =>
    # namespace :admin do
    #   map.resources :users
    # end
    with_node node_type: 'block', caller: { node_type: 'send', receiver: { not: nil }, message: 'namespace' } do
      if node.arguments.length > 0
        block_argument = node.arguments.first.to_source
        new_routes = []
        new_routes << "namespace {{caller.arguments}} do\n"
        new_routes << generate_new_child_routes(node, block_argument)
        new_routes << 'end'
        replace_with new_routes.join
      end
    end
  end

  within_file Synvert::RAILS_ROUTE_FILES do
    # map.with_options :controller => "manage" do |manage|
    #   manage.manage_index "manage_index", :action => "index"
    #   manage.manage_intro "manage_intro", :action => "intro"
    # end
    # =>
    # manage.manage_index "manage_index", :action => "index", :controller => "manage"
    # manage.manage_intro "manage_intro", :action => "intro", :controller => "manage"
    with_node node_type: 'block', caller: { node_type: 'send', message: 'with_options' } do
      block_argument = node.arguments.first.to_source
      new_routes = []
      node.body.each do |child_node|
        new_route = child_node.to_source.sub(block_argument, 'map')
        new_routes << "#{new_route}, {{caller.arguments}}\n"
      end
      replace_with new_routes.join
    end
  end

  within_file Synvert::RAILS_ROUTE_FILES do
    # map.resources :posts, :collection => { :generate_pdf => :get }, :member => {:activate => :post} do |posts|
    #   posts.resources :comments
    # end
    # =>
    # resources :posts do
    #   collection do
    #     get :generate_pdf
    #   end
    #   member do
    #     post :activate
    #   end
    #   map.resources :comments
    # end
    %w[resource resources].each do |message|
      within_node node_type: 'block', caller: { node_type: 'send', receiver: { not: nil }, message: message } do
        block_argument = node.arguments.first.to_source
        hash_argument = node.caller.arguments.last
        new_routes = ''
        if hash_argument.type == :hash && (hash_argument.key?(:collection) || hash_argument.key?(:member))
          collection_routes = hash_argument.collection_value
          member_routes = hash_argument.member_value
          other_options_code = reject_keys_from_hash(hash_argument, :collection, :member)
          new_routes = []
          new_routes << if other_options_code.length > 0
                          "#{message} {{caller.arguments.first}}, #{other_options_code} do\n"
                        else
                          "#{message} {{caller.arguments.first}} do\n"
                        end
          new_routes << generate_new_collection_routes(collection_routes) if collection_routes
          new_routes << generate_new_member_routes(member_routes) if member_routes
        else
          new_routes << "#{message} {{caller.arguments}} do\n"
        end
        new_routes << generate_new_child_routes(node, block_argument)
        new_routes << 'end'
        replace_with new_routes.join
      end
    end
  end

  within_file Synvert::RAILS_ROUTE_FILES do
    # map.connect "/main/:id", :controller => "main", :action => "home"
    # => match "/main/:id", :to => "main#home"
    within_node node_type: 'send', receiver: 'map', message: 'connect' do
      if_exist_node node_type: 'hash' do
        hash_node = node.arguments.last
        if hash_node.key?(:action) && hash_node.key?(:controller)
          controller_action_name = extract_controller_action_name(hash_node)
          method = hash_node.key?(:method) ? hash_node.method_value.to_value : 'match'
          other_options_code = reject_keys_from_hash(hash_node, :controller, :action, :method)
          if other_options_code.length > 0
            replace_with "#{method} {{arguments.first}}, :to => #{wrap_with_quotes(controller_action_name)}, #{other_options_code}"
          else
            replace_with "#{method} {{arguments.first}}, :to => #{wrap_with_quotes(controller_action_name)}"
          end
        end
      end
    end

    # map.root :controller => "home", :action => :index
    # => root :to => "home#index"
    within_node node_type: 'send', receiver: 'map', message: 'root' do
      hash_node = node.arguments.last
      controller_action_name = extract_controller_action_name(hash_node)
      subdomain_node = extract_subdomain_node(hash_node)
      if subdomain_node
        replace_with "root :to => #{wrap_with_quotes(controller_action_name)}, :constraints => {:subdomain => #{subdomain_node.to_source}}"
      else
        replace_with "root :to => #{wrap_with_quotes(controller_action_name)}"
      end
    end

    # map.resoures :questions, :collection => {:generate_csv => :get}, :member => {:activate => :post}
    # =>
    # resources :questions do
    #   collection do
    #     get :generate_csv
    #   end
    #   member do
    #     post :activate
    #   edn
    # end
    %w[resource resources].each do |message|
      with_node node_type: 'send', receiver: 'map', message: message do
        hash_argument = node.arguments.last
        if hash_argument.type == :hash && (hash_argument.key?(:collection) || hash_argument.key?(:member))
          collection_routes = hash_argument.collection_value
          member_routes = hash_argument.member_value
          other_options_code = reject_keys_from_hash(hash_argument, :collection, :member)
          new_routes = []
          new_routes << if other_options_code.length > 0
                          "#{message} {{arguments.first}}, #{other_options_code} do\n"
                        else
                          "#{message} {{arguments.first}} do\n"
                        end
          new_routes << generate_new_collection_routes(collection_routes) if collection_routes
          new_routes << generate_new_member_routes(member_routes) if member_routes
          new_routes << 'end'
          replace_with new_routes.join
        else
          replace_with "#{message} {{arguments}}"
        end
      end
    end

    # map.connect "/:controller/:action/:id"
    # => match "/:controller(/:action(/:id))(.:format)"
    with_node node_type: 'send',
              receiver: 'map',
              message: 'connect',
              arguments: { first: %r|:controller/:action/:id| } do
      replace_with 'match "/:controller(/:action(/:id))(.:format)"'
    end

    # map.connect "audio/:action/:id", :controller => "audio"
    # => match "audio(/:action(/:id))(.:format)", :controller => "audio"
    with_node node_type: 'send', receiver: 'map', message: 'connect', arguments: { first: %r|(.*?)/:action/:id| } do
      options_node = node.arguments.last
      if options_node.type == :hash && options_node.key?(:controller)
        controller_name = options_node.controller_value.to_value
        replace_with "match #{wrap_with_quotes(controller_name + "(/:action(/:id))(.:format)")}, {{arguments.last}}"
      end
    end

    # map.connect "video/:action", :controller => "video"
    # => match "video(/:action)(.:format)", :controller => "video"
    with_node node_type: 'send', receiver: 'map', message: 'connect', arguments: { first: %r|(.*?)/:action['"]$| } do
      options_node = node.arguments.last
      if options_node.type == :hash && options_node.key?(:controller)
        controller_name = options_node.controller_value.children.last
        replace_with "match #{wrap_with_quotes(controller_name + "(/:action)(.:format)")}, {{arguments.last}}"
      end
    end

    # named routes
    # map.admin_signup "/admin_signup", :controller => "admin_signup", :action => "new", :method => "post"
    # => post "/admin_signup", :to => "admin_signup#new", :as => "admin_signup"
    within_node node_type: 'send', receiver: 'map' do
      message = node.message
      unless %i[root connect resource resources].include? message
        url = node.arguments.first.to_value
        hash_node = node.arguments.last
        if hash_node.type == :hash && hash_node.key?(:controller)
          if hash_node.key?(:action) || url !~ /:action/
            controller_action_name =
              if hash_node.key?(:action)
                extract_controller_action_name(hash_node)
              else
                "#{hash_node.controller_value.to_value}#index"
              end
            method = extract_method(hash_node)
            subdomain_node = extract_subdomain_node(hash_node)
            other_options_code = reject_keys_from_hash(hash_node, :controller, :action, :method, :conditions)
            other_options_code += ":constraints => {:subdomain => #{subdomain_node.to_source}}" if subdomain_node
            if other_options_code.length > 0
              replace_with "#{method} {{arguments.first}}, :to => #{wrap_with_quotes(controller_action_name)}, #{other_options_code}, :as => #{wrap_with_quotes(message.to_s)}"
            else
              replace_with "#{method} {{arguments.first}}, :to => #{wrap_with_quotes(controller_action_name)}, :as => #{wrap_with_quotes(message.to_s)}"
            end
          else
            replace_with 'match {{arguments}}'
          end
        end
      end
    end
  end
end
