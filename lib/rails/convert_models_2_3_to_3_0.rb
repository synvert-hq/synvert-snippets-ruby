# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_models_2_3_to_3_0' do
  description <<-EOF
It converts rails models from 2.3 to 3.0.

    named_scope :active, :conditions => {:active => true}, :order => "created_at desc"
    named_scope :my_active, lambda { |user| {:conditions => ["user_id = ? and active = ?", user.id, true], :order => "created_at desc"} }
    =>
    scope :active, where(:active => true).order("created_at desc")
    scope :my_active, lambda { |user| where("user_id = ? and active = ?", user.id, true).order("created_at desc") }

    default_scope :order => "id DESC"
    =>
    default_scope order("id DESC")

    Post.find(:all, :limit => 2)
    Post.find(:all)
    Post.find(:first)
    Post.find(:last, :conditions => {:title => "test"})
    Post.first(:conditions => {:title => "test"})
    Post.all(:joins => :comments)
    =>
    Post.limit(2)
    Post.all
    Post.first
    Post.where(:title => "test").last
    Post.where(:title => "test").first
    Post.joins(:comments)

    Post.find_in_batches(:conditions => {:title => "test"}, :batch_size => 100) do |posts|
    end
    Post.find_in_batches(:conditions => {:title => "test"}) do |posts|
    end
    =>
    Post.where(:title => "test").find_each(:batch_size => 100) do |post|
    end
    Post.where(:title => "test").find_each do |post|
    end

    with_scope(:find => {:conditions => {:active => true}}) { Post.first }
    with_exclusive_scope(:find => {:limit =>1}) { Post.last }
    =>
    with_scope(where(:active => true)) { Post.first }
    with_exclusive_scope(limit(1)) { Post.last }

    Client.count("age", :conditions => {:active => true})
    Client.average("orders_count", :conditions => {:active => true})
    Client.min("age", :conditions => {:active => true})
    Client.max("age", :conditions => {:active => true})
    Client.sum("orders_count", :conditions => {:active => true})
    =>
    Client.where(:active => true).count("age")
    Client.where(:active => true).average("orders_count")
    Client.where(:active => true).min("age")
    Client.where(:active => true).max("age")
    Client.where(:active => true).sum("orders_count")


    self.errors.on(:email).present?
    =>
    self.errors[:email].present?

    self.errors.add_to_base("error message")
    =>
    self.errors.add(:base, "error message")

    self.save(false)
    =>
    self.save(:validate => false)

    Post.update_all({:title => "title"}, {:title => "test"})
    Post.update_all("title = \'title\'", "title = \'test\'")
    Post.update_all("title = \'title\'", ["title = ?", title])
    Post.update_all({:title => "title"}, {:title => "test"}, {:limit => 2})
    =>
    Post.where(:title => "test").update_all(:title => "title")
    Post.where("title = \'test\'").update_all("title = \'title\'")
    Post.where(["title = ?", title]).update_all("title = \'title\'")
    Post.where(:title => "test").limit(2).update_all(:title => "title")

    Post.delete_all("title = \'test\'")
    Post.delete_all(["title = ?", title])
    =>
    Post.where("title = \'test\'").delete_all
    Post.where("title = ?", title).delete_all

    Post.destroy_all("title = \'test\'")
    Post.destroy_all(["title = ?", title])
    =>
    Post.where("title = \'test\'").destroy_all
    Post.where("title = ?", title).destroy_all
  EOF

  keys = %i[conditions order joins select from having group include limit offset lock readonly]
  keys_converters = {
    :conditions => :where,
    :include => :includes
  }

  helper_method :generate_new_queries do |hash_node|
    new_queries = []
    hash_node.children.each do |pair_node|
      if keys.include? pair_node.key.to_value
        method = keys_converters[pair_node.key.to_value] || pair_node.key.to_value
        new_queries << "#{method}(#{strip_brackets(pair_node.value.to_source)})"
      end
    end
    new_queries.join('.')
  end

  helper_method :generate_batch_options do |hash_node|
    options = []
    hash_node.children.each do |pair_node|
      if %i[start batch_size].include? pair_node.key.to_value
        options << pair_node.to_source
      end
    end
    options.join(', ')
  end

  within_files '{app,lib}/**/*.rb' do
    # named_scope :active, :conditions => {:active => true}
    # =>
    # named_scope :active, where(:active => true)
    #
    # default_scope :conditions => {:active => true}
    # =>
    # default_scope where(:active => true)
    %w(named_scope default_scope).each do |message|
      within_node type: 'send', message: message, arguments: { last: { type: 'hash' } } do
        with_node type: 'hash' do
          if keys.any? { |key| node.has_key? key }
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
      within_node type: 'send', message: message, arguments: { last: { type: 'block' } } do
        within_node type: 'block' do
          with_node type: 'hash' do
            if keys.any? { |key| node.has_key? key }
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
      replace_with add_receiver_if_necessary('scope {{arguments}}')
    end

    # scoped(:conditions => {:active => true})
    # =>
    # where(:active => true)
    within_node type: 'send', message: 'scoped' do
      if node.arguments.length == 1
        argument_node = node.arguments.first
        if :hash == argument_node.type && keys.any? { |key| argument_node.has_key? key }
          replace_with add_receiver_if_necessary(generate_new_queries(argument_node))
        end
      end
    end

    # Post.all(:joins => :comments)
    # =>
    # Post.joins(:comments).all
    within_node type: 'send', message: 'all', arguments: { size: 1 } do
      argument_node = node.arguments.first
      if :hash == argument_node.type && keys.any? { |key| argument_node.has_key? key }
        replace_with add_receiver_if_necessary(generate_new_queries(argument_node))
      end
    end

    %w(first last).each do |message|
      # Post.first(:conditions => {:title => "test"})
      # =>
      # Post.where(:title => "test").first
      within_node type: 'send', message: message, arguments: { size: 1 } do
        argument_node = node.arguments.first
        if :hash == argument_node.type && keys.any? { |key| argument_node.has_key? key }
          replace_with add_receiver_if_necessary("#{generate_new_queries(argument_node)}.#{message}")
        end
      end
    end

    %w(count average min max sum).each do |message|
      # Client.count("age", :conditions => {:active => true})
      # Client.average("orders_count", :conditions => {:active => true})
      # Client.min("age", :conditions => {:active => true})
      # Client.max("age", :conditions => {:active => true})
      # Client.sum("orders_count", :conditions => {:active => true})
      # =>
      # Client.where(:active => true).count("age")
      # Client.where(:active => true).average("orders_count")
      # Client.where(:active => true).min("age")
      # Client.where(:active => true).max("age")
      # Client.where(:active => true).sum("orders_count")
      within_node type: 'send', message: message, arguments: { size: 2 } do
        argument_node = node.arguments.last
        if :hash == argument_node.type && keys.any? { |key| argument_node.has_key? key }
          replace_with add_receiver_if_necessary("#{generate_new_queries(argument_node)}.#{message}({{arguments.first}})")
        end
      end
    end

    # Post.find(:all, :limit => 2)
    # =>
    # Post.where(:limit => 2)
    with_node type: 'send', message: 'find', arguments: { size: 2, first: :all } do
      argument_node = node.arguments.last
      if :hash == argument_node.type && keys.any? { |key| argument_node.has_key? key }
        replace_with add_receiver_if_necessary(generate_new_queries(argument_node))
      end
    end

    # Post.find(:all)
    # =>
    # Post.all
    with_node type: 'send', message: 'find', arguments: { size: 1, first: :all } do
      replace_with add_receiver_if_necessary('all')
    end

    %i[first last].each do |message|
      # Post.find(:last, :conditions => {:title => "test"})
      # =>
      # Post.where(:title => "title").last
      within_node type: 'send', message: 'find', arguments: { size: 2, first: message } do
        argument_node = node.arguments.last
        if :hash == argument_node.type && keys.any? { |key| argument_node.has_key? key }
          replace_with add_receiver_if_necessary("#{generate_new_queries(argument_node)}.#{message}")
        end
      end

      # Post.find(:first)
      # =>
      # Post.first
      within_node type: 'send', message: 'find', arguments: { size: 1, first: message } do
        replace_with add_receiver_if_necessary(message)
      end
    end

    # Post.update_all({:title => "title"}, {:title => "test"})
    # Post.update_all("title = \'title\'", "title = \'test\'")
    # Post.update_all("title = \'title\'", ["title = ?", title])
    # =>
    # Post.where(:title => "test").update_all(:title => "title")
    # Post.where("title = \'test\'").update_all("title = \'title\'")
    # Post.where("title = ?", title).update_all("title = \'title\'")
    within_node type: 'send', message: :update_all, arguments: { size: 2 } do
      updates_node, conditions_node = node.arguments
      replace_with add_receiver_if_necessary("where(#{(strip_brackets(conditions_node.to_source))}).update_all(#{strip_brackets(updates_node.to_source)})")
    end

    # Post.update_all({:title => "title"}, {:title => "test"}, {:limit => 2})
    # =>
    # Post.where(:title => "test").limit(2).update_all(:title => "title")
    within_node type: 'send', message: :update_all, arguments: { size: 3 } do
      updates_node, conditions_node, options_node = node.arguments
      replace_with add_receiver_if_necessary("where(#{strip_brackets(conditions_node.to_source)}).#{generate_new_queries(options_node)}.update_all(#{strip_brackets(updates_node.to_source)})")
    end

    # Post.delete_all("title = \'test\'")
    # Post.delete_all(["title = ?", title])
    # =>
    # Post.where("title = \'test\'").delete_all
    # Post.where("title = ?", title).delete_all
    #
    # Post.destroy_all("title = \'test\'")
    # Post.destroy_all(["title = ?", title])
    # =>
    # Post.where("title = \'test\'").destroy_all
    # Post.where("title = ?", title).destroy_all
    %w(delete_all destroy_all).each do |message|
      within_node type: 'send', message: message, arguments: { size: 1 } do
        conditions_node = node.arguments.first
        replace_with add_receiver_if_necessary("where(#{strip_brackets(conditions_node.to_source)}).#{message}")
      end
    end

    %w(find_each find_in_batches).each do |message|
      # Post.find_each(:conditions => {:title => "test"}, :batch_size => 100) do |post|
      # end
      # =>
      # Post.where(:title => "test").find_each(:batch_size => 100) do |post|
      # end
      #
      # Post.find_in_batches(:conditions => {:title => "test"}, :batch_size => 100) do |posts|
      # end
      # =>
      # Post.where(:title => "test").find_in_batches(:batch_size => 100) do |posts|
      # end
      within_node type: 'send', message: message, arguments: { size: 1 } do
        argument_node = node.arguments.first
        if :hash == argument_node.type && keys.any? { |key| argument_node.has_key? key }
          batch_options = generate_batch_options(argument_node)
          if batch_options.length > 0
            replace_with add_receiver_if_necessary("#{generate_new_queries(argument_node)}.#{message}(#{batch_options})")
          else
            replace_with add_receiver_if_necessary("#{generate_new_queries(argument_node)}.#{message}")
          end
        end
      end
    end

    %w(with_scope with_exclusive_scope).each do |message|
      # with_scope(:find => {:conditions => {:active => true}}) { Post.first }
      # =>
      # with_scope(where(:active => true)) { Post.first }
      #
      # with_exclusive_scope(:find => {:limit =>1}) { Post.last }
      # =>
      # with_exclusive_scope(limit(1)) { Post.last }
      within_node type: 'send', message: message, arguments: { size: 1 } do
        argument_node = node.arguments.first
        if :hash == argument_node.type && argument_node.has_key?(:find)
          replace_with "#{message}(#{generate_new_queries(argument_node.hash_value(:find))})"
        end
      end
    end
  end

  within_files '{app,lib,test}/**/*.rb' do
    # self.errors.on(:email).present?
    # =>
    # self.errors[:email].present?
    with_node type: 'send', message: 'on', receiver: /errors$/ do
      replace_with '{{receiver}}[{{arguments}}]'
    end

    # self.errors.add_to_base("error message")
    # =>
    # self.errors.add(:base, "error message")
    with_node type: 'send', message: 'add_to_base', receiver: { type: 'send', message: 'errors' } do
      replace_with '{{receiver}}.add(:base, {{arguments}})'
    end

    # self.save(false)
    # =>
    # self.save(:validate => false)
    with_node type: 'send', message: 'save', arguments: [false] do
      replace_with add_receiver_if_necessary('save(:validate => false)')
    end
  end
end
