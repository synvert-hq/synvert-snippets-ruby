Synvert::Rewriter.new "convert_models_2_3_to_3_0" do
  description <<-EOF
It converts rails models from 2.3 to 3.0.
  EOF

  KEYS = [:conditions, :order, :joins, :select, :from, :having, :group, :include, :limit, :offset, :lock, :readonly]
  KEYS_CONVERTERS = {
    :conditions => :where,
    :include => :includes
  }

  helper_method :generate_new_queries do |hash_node|
    new_queries = []
    hash_node.children.each do |pair_node|
      method = KEYS_CONVERTERS[pair_node.key.to_value] || pair_node.key.to_value
      new_queries << "#{method}(#{strip_brackets(pair_node.value.to_source)})"
    end
    new_queries.join(".")
  end

  %w(app/**/*.rb lib/**/*.rb).each do |file_pattern|
    within_files file_pattern do
      # named_scope :active, :conditions => {:active => true}
      # =>
      # named_scope :active, where(:active => true)
      #
      # default_scope :conditions => {:active => true}
      # =>
      # default_scope where(:active => true)
      %w(named_scope default_scope).each do |message|
        within_node type: 'send', message: message, arguments: {last: {type: 'hash'}} do
          with_node type: 'hash' do
            if KEYS.any? { |key| node.has_key? key }
              replace_with generate_new_queries(node)
            end
          end
        end

        # named_scope :active, lambda { {:conditions => {:active => true}} }
        # =>
        # named_scope :active, lambda { where(:active => true) }
        #
        # default_scope :active, lambda { {:conditions => {:active => true}} }
        # =>
        # default_scope :active, lambda { where(:active => true) }
        within_node type: 'send', message: message, arguments: {last: {type: 'block'}} do
          within_node type: 'block' do
            with_node type: 'hash' do
              if KEYS.any? { |key| node.has_key? key }
                replace_with generate_new_queries(node)
              end
            end
          end
        end
      end

      # named_scope :active, where(:active => true)
      # =>
      # scope :active, where(:active => true)
      with_node type: 'send', message: 'named_scope' do
        replace_with add_receiver_if_necessary("scope {{arguments}}")
      end

      # scoped(:conditions => {:active => true})
      # =>
      # where(:active => true)
      within_node type: 'send', message: 'scoped' do
        if node.arguments.length == 1
          argument_node = node.arguments.first
          if KEYS.any? { |key| argument_node.has_key? key }
            replace_with add_receiver_if_necessary(generate_new_queries(argument_node))
          end
        end
      end

      within_node type: 'send', message: 'all', arguments: {size: 1} do
        argument_node = node.arguments.first
        if :hash == argument_node.type && KEYS.any? { |key| argument_node.has_key? key }
          replace_with add_receiver_if_necessary(generate_new_queries(argument_node))
        end
      end

      %w(first last).each do |message|
        within_node type: 'send', message: message, arguments: {size: 1} do
          argument_node = node.arguments.first
          if :hash == argument_node.type && KEYS.any? { |key| argument_node.has_key? key }
            replace_with add_receiver_if_necessary("#{generate_new_queries(argument_node)}.#{message}")
          end
        end
      end

      %w(count average min max sum).each do |message|
        within_node type: 'send', message: message, arguments: {size: 2} do
          argument_node = node.arguments.last
          if :hash == argument_node.type && KEYS.any? { |key| argument_node.has_key? key }
            replace_with add_receiver_if_necessary("#{generate_new_queries(argument_node)}.#{message}({{arguments.first}})")
          end
        end
      end

      with_node type: 'send', message: 'find', arguments: {size: 2, first: :all} do
        argument_node = node.arguments.last
        if :hash == argument_node.type && KEYS.any? { |key| argument_node.has_key? key }
          replace_with add_receiver_if_necessary(generate_new_queries(argument_node))
        end
      end

      with_node type: 'send', message: 'find', arguments: {size: 1, first: :all} do
        replace_with add_receiver_if_necessary("all")
      end

      [:first, :last].each do |message|
        within_node type: 'send', message: 'find', arguments: {size: 2, first: message} do
          argument_node = node.arguments.last
          if :hash == argument_node.type && KEYS.any? { |key| argument_node.has_key? key }
            replace_with add_receiver_if_necessary("#{generate_new_queries(argument_node)}.#{message}")
          end
        end

        within_node type: 'send', message: 'find', arguments: {size: 1, first: message} do
          replace_with add_receiver_if_necessary(message)
        end
      end

      %w(with_scope with_exclusive_scope).each do |message|
        within_node type: 'send', message: message, arguments: {size: 1} do
          argument_node = node.arguments.first
          if :hash == argument_node.type && argument_node.has_key?(:find)
            replace_with "#{message}(#{generate_new_queries(argument_node.hash_value(:find))})"
          end
        end
      end
    end
  end

  %w(app/**/*.rb lib/**/*.rb test/**/*_test.rb).each do |file_pattern|
    within_files file_pattern do
      with_node type: 'send', message: 'on', receiver: /errors$/ do
        replace_with "{{receiver}}[{{arguments}}]"
      end

      with_node type: 'send', message: 'save', arguments: [false] do
        # recevier could be nil
        replace_with add_receiver_if_necessary("save(:validate => false)")
      end
    end
  end
end
