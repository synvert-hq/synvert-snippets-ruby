# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_active_record_dirty_5_0_to_5_1' do
  description <<~EOS
    It converts ActiveRecord::Dirty 5.0 to 5.1

    ```ruby
    class Post < ActiveRecord::Base
      before_create :call_before_create
      before_update :call_before_update, if: :title_changed?
      before_save :call_before_save, if: -> { status_changed? || summary_changed? }
      after_create :call_after_create
      after_update :call_after_update, if: :title_changed?
      after_save :call_after_save, if: -> { status_changed? || summary_changed? }

      def call_before_create
        if title_changed?
          changes
        end
      end

      def call_after_create
        if title_changed?
          changes
        end
      end
    end
    ```

    =>

    ```ruby
    class Post < ActiveRecord::Base
      before_create :call_before_create
      before_update :call_before_update, if: :will_save_change_to_title?
      before_save :call_before_save, if: -> { will_save_change_to_status? || will_save_change_to_summary? }
      after_create :call_after_create
      after_update :call_after_update, if: :saved_change_to_title?
      after_save :call_after_save, if: -> { saved_change_to_status? || saved_change_to_summary? }

      def call_before_create
        if will_save_change_to_title?
          changes_to_save
        end
      end

      def call_after_create
        if saved_change_to_title?
          saved_changes
        end
      end
    end
    ```
  EOS

  if_gem 'activerecord', { gte: '5.1.0' }

  BEFORE_CALLBACK_CHANGES = {
    /(\w+)_changed\?$/ => 'will_save_change_to_{{attribute}}?',
    /(\w+)_change$/ => '{{attribute}}_change_to_be_saved',
    /(\w+)_was$/ => '{{attribute}}_in_database',
    'changes' => 'changes_to_save',
    'changed?' => 'has_changes_to_save?',
    'changed' => 'changed_attribute_names_to_save',
    'changed_attributes' => 'attributes_in_database'
  }

  AFTER_CALLBACK_CHANGES = {
    /(\w+)_changed\?$/ => 'saved_change_to_{{attribute}}?',
    /(\w+)_change$/ => 'saved_change_to_{{attribute}}',
    /(\w+)_was$/ => '{{attribute}}_before_last_save',
    'changes' => 'saved_changes',
    'changed?' => 'saved_changes?',
    'changed' => 'saved_changes.keys',
    'changed_attributes' => 'saved_changes.transform_values(&:first)'
  }

  BEFORE_CALLBACK_NAMES = %i[before_create before_update before_save]

  AFTER_CALLBACK_NAMES = %i[
    after_create
    after_update
    after_save
    after_commit
    after_create_commit
    after_update_commit
    after_save_commit
  ]

  # convert ActiveRecord::Dirty api change
  helper_method :convert_dirty_api_change do |before_name, after_name, attributes|
    # after_save :invalidate_cache, if: :status_changed?
    with_node type: 'sym', to_value: before_name do
      if before_name.is_a?(Regexp)
        if node.to_value =~ before_name && attributes.include?($1)
          replace_with ":#{after_name.sub('{{attribute}}', $1)}"
        end
      else
        replace_with after_name
      end
    end

    # after_save :invalidate_cache, if: -> { title_changed? || summary_chagned? }
    #
    # or
    #
    # after_save :invalidate_cache
    # def invalidate_cache
    #   if title_chagned? || summary_changed?
    # . end
    # end
    with_node type: 'send', receiver: nil, message: before_name do
      if before_name.is_a?(Regexp)
        if node.message.to_s =~ before_name && attributes.include?($1)
          replace_with after_name.sub('{{attribute}}', $1)
        end
      else
        replace_with after_name
      end
    end
  end

  # find callbacks and convert them
  helper_method :find_callbacks_and_convert do |callback_names, callback_changes, attributes|
    custom_callback_names = []

    callback_names.each do |callback_name|
      # find callback like
      #
      #     after_save :invalidate_cache, if: :status_changed?
      with_node type: 'send', receiver: nil, message: callback_name do
        custom_callback_names << node.arguments[0].to_value if !node.arguments.empty? && node.arguments[0].type == :sym
        callback_changes.each do |before_name, after_name|
          convert_dirty_api_change(before_name, after_name, attributes)
        end
      end

      # find callback like
      #
      #     before_save do
      #       if status_chagned?
      #       end
      #     end
      with_node type: 'block', caller: { type: 'send', receiver: nil, message: callback_name } do
        callback_changes.each do |before_name, after_name|
          convert_dirty_api_change(before_name, after_name, attributes)
        end
      end
    end

    # find callback method like
    #
    #     after_save :invalidate_cache
    #     def invalidate_cache
    #     end
    with_node type: 'def' do
      if callback_names.include?(node.name) || custom_callback_names.include?(node.name)
        callback_changes.each do |before_name, after_name|
          convert_dirty_api_change(before_name, after_name, attributes)
        end
      end
    end
  end

  # read model attributes from db/schema.rb
  object_attributes = {}
  within_file 'db/schema.rb' do
    within_node type: 'block', caller: { type: 'send', message: 'create_table' } do
      object_name = node.caller.arguments.first.to_value.singularize
      object_attributes[object_name] = []
      with_node type: 'send', receiver: 't', message: { not: 'index' } do
        unless node.arguments.empty?
          attribute_name = node.arguments.first.to_value
          object_attributes[object_name] << attribute_name
        end
      end
    end
  end

  within_files 'app/{models,observers}/**/*.rb' do
    within_node type: 'class' do
      object_name = node.name.to_source.underscore

      find_callbacks_and_convert(BEFORE_CALLBACK_NAMES, BEFORE_CALLBACK_CHANGES, object_attributes[object_name])
      find_callbacks_and_convert(AFTER_CALLBACK_NAMES, AFTER_CALLBACK_CHANGES, object_attributes[object_name])
    end
  end
end
