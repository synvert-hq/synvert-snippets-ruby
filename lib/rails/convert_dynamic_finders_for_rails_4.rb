# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_dynamic_finders_for_rails_4' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It converts rails 4 dynamic finders to arel syntax.

    ```ruby
    find_or_initialize_by_...
    find_or_create_by_...
    ```

    =>

    ```ruby
    find_or_initialize_by(...)
    find_or_create_by(...)
    ```
  EOS

  attributes = ['id']
  within_file 'db/schema.rb' do
    within_node node_type: 'block', caller: { node_type: 'send', message: 'create_table' } do
      with_node node_type: 'send', receiver: 't' do
        attributes << node.arguments.first.to_value
      end
    end
  end

  helper_method :dynamic_finder_to_hash do |prefix|
    fields = node.message.to_s[prefix.length..-1].split('_and_')
    return nil if (fields - attributes).present?

    if fields.length == node.arguments.length && :hash != node.arguments.first.type
      fields.length.times.map { |i| fields[i] + ': ' + node.arguments[i].to_source }
            .join(', ')
    else
      '{{arguments}}'
    end
  end

  if_gem 'rails', '>= 4.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # find_or_initialize_by_... => find_or_initialize_by(...)
    with_node node_type: 'send', message: /^find_or_initialize_by_/ do
      group do
        hash_params = dynamic_finder_to_hash('find_or_initialize_by_')
        if hash_params
          replace :message, with: 'find_or_initialize_by'
          replace :arguments, with: hash_params
        end
      end
    end

    # find_or_create_by_... => find_or_create_by(...)
    with_node node_type: 'send', message: /^find_or_create_by_/ do
      group do
        hash_params = dynamic_finder_to_hash('find_or_create_by_')
        if hash_params
          replace :message, with: 'find_or_create_by'
          replace :arguments, with: hash_params
        end
      end
    end
  end
end