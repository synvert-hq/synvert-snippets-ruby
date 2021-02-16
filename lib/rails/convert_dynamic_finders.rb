# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_dynamic_finders' do
  description <<~EOF
    It converts rails dynamic finders to arel syntax.
    
        find_all_by_... => where(...)
        find_by_... => where(...).first
        find_last_by_... => where(...).last
        scoped_by_... => where(...)
        find_or_initialize_by_... => find_or_initialize_by(...)
        find_or_create_by_... => find_or_create_by(...)
  EOF

  attributes = ['id']
  within_file 'db/schema.rb' do
    within_node type: 'block', caller: { type: 'send', message: 'create_table' } do
      with_node type: 'send', receiver: 't' do
        attributes << node.arguments.first.to_value
      end
    end
  end

  helper_method :dynamic_finder_to_hash do |prefix|
    fields = node.message.to_s[prefix.length..-1].split('_and_')
    return nil if (fields - attributes).present?

    if fields.length == node.arguments.length && :hash != node.arguments.first.type
      fields.length.times.map { |i| fields[i] + ': ' + node.arguments[i].to_source }.join(', ')
    else
      '{{arguments}}'
    end
  end

  if_gem 'rails', { gte: '3.0.0' }

  within_files '**/*.rb' do
    # find_all_by_... => where(...)
    with_node type: 'send', message: /^find_all_by_/ do
      hash_params = dynamic_finder_to_hash('find_all_by_')
      replace_with add_receiver_if_necessary("where(#{hash_params})") if hash_params
    end

    # find_by_... => where(...).first
    with_node type: 'send', message: /^find_by_/ do
      if :find_by_id == node.message
        replace_with add_receiver_if_necessary('find_by(id: {{arguments}})')
      elsif :find_by_sql != node.message
        hash_params = dynamic_finder_to_hash('find_by_')
        replace_with add_receiver_if_necessary("find_by(#{hash_params})") if hash_params
      end
    end

    # find_last_by_... => where(...).last
    with_node type: 'send', message: /^find_last_by_/ do
      hash_params = dynamic_finder_to_hash('find_last_by_')
      replace_with add_receiver_if_necessary("where(#{hash_params}).last") if hash_params
    end

    # scoped_by_... => where(...)
    with_node type: 'send', message: /^scoped_by_/ do
      hash_params = dynamic_finder_to_hash('scoped_by_')
      replace_with add_receiver_if_necessary("where(#{hash_params})") if hash_params
    end
  end

  if_gem 'rails', { gte: '4.0.0' }

  within_files '**/*.rb' do
    # find_or_initialize_by_... => find_or_initialize_by(...)
    with_node type: 'send', message: /^find_or_initialize_by_/ do
      hash_params = dynamic_finder_to_hash('find_or_initialize_by_')
      replace_with add_receiver_if_necessary("find_or_initialize_by(#{hash_params})") if hash_params
    end

    # find_or_create_by_... => find_or_create_by(...)
    with_node type: 'send', message: /^find_or_create_by_/ do
      hash_params = dynamic_finder_to_hash('find_or_create_by_')
      replace_with add_receiver_if_necessary("find_or_create_by(#{hash_params})") if hash_params
    end
  end
end
