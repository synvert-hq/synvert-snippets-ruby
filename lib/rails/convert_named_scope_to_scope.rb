Synvert::Rewriter.new 'convert_named_scope_to_scope' do
  description "It converts named_scope to scope."

  if_gem 'rails', {gte: '2.3.0'}

  KEYS = [:conditions, :order, :joins, :select, :from, :having, :group, :include, :limit, :offset, :lock, :readonly]
  KEYS_CONVERTERS = {
    :conditions => :where,
    :include => :includes
  }

  helper_method :clean_hash_and_array do |hash_str|
    (hash_str[0] == '{' && hash_str[-1] == '}') || (hash_str[0] == '[' && hash_str[-1] == ']') ? hash_str[1...-1] : hash_str
  end

  helper_method :generate_new_queries do |hash_node|
    new_queries = []
    hash_node.children.each do |pair_node|
      method = KEYS_CONVERTERS[pair_node.key.to_value] || pair_node.key.to_value
      new_queries << "#{method}(#{clean_hash_and_array(pair_node.value.to_source)})"
    end
    new_queries.join(".")
  end

  %w(app/models/**/*.rb lib/**/*.rb).each do |file_pattern|
    within_files file_pattern do
      # named_scope :active, :conditions => {:active => true}
      # =>
      # named_scope :active, where(:active => true)
      within_node type: 'send', message: 'named_scope', arguments: {last: {type: 'hash'}} do
        with_node type: 'hash' do
          if KEYS.any? { |key| node.has_key? key }
            replace_with generate_new_queries(node)
          end
        end
      end

      # named_scope :active, lambda { {:conditions => {:active => true}} }
      # =>
      # named_scope :active, lambda { where(:active => true) }
      within_node type: 'send', message: 'named_scope', arguments: {last: {type: 'block'}} do
        within_node type: 'block' do
          with_node type: 'hash' do
            if KEYS.any? { |key| node.has_key? key }
              replace_with generate_new_queries(node)
            end
          end
        end
      end

      # named_scope :active, where(:active => true)
      # =>
      # scope :active, where(:active => true)
      with_node type: 'send', message: 'named_scope' do
        if node.receiver
          replace_with "{{receiver}}.scope {{arguments}}"
        else
          replace_with "scope {{arguments}}"
        end
      end
    end
  end
end
