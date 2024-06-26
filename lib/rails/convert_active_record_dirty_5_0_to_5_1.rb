# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_active_record_dirty_5_0_to_5_1' do
  configure(parser: Synvert::PRISM_PARSER)

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

  if_gem 'activerecord', '>= 5.1'

  before_callback_changes = {
    /(\w+)_changed\?$/ => 'will_save_change_to_{{attribute}}?',
    /(\w+)_change$/ => '{{attribute}}_change_to_be_saved',
    /(\w+)_was$/ => '{{attribute}}_in_database',
    'changes' => 'changes_to_save',
    'changed?' => 'has_changes_to_save?',
    'changed' => 'changed_attribute_names_to_save',
    'changed_attributes' => 'attributes_in_database'
  }

  after_callback_changes = {
    /(\w+)_changed\?$/ => 'saved_change_to_{{attribute}}?',
    /(\w+)_change$/ => 'saved_change_to_{{attribute}}',
    /(\w+)_was$/ => '{{attribute}}_before_last_save',
    'changes' => 'saved_changes',
    'changed?' => 'saved_changes?',
    'changed' => 'saved_changes.keys',
    'changed_attributes' => 'saved_changes.transform_values(&:first)'
  }

  before_callback_names = %i[before_create before_update before_save]

  after_callback_names = %i[
    after_create
    after_update
    after_save
    after_commit
    after_create_commit
    after_update_commit
    after_save_commit
  ]

  skip_names = {}

  # convert ActiveRecord::Dirty api change
  #
  # after_save :invalidate_cache, if: -> { title_changed? || summary_chagned? }
  #
  # or
  #
  # after_save :invalidate_cache
  # def invalidate_cache
  #   if title_chagned? || summary_changed?
  #   end
  # end
  helper_method :convert_send_dirty_api_change do |before_name, after_name|
    with_node node_type: 'call_node', name: before_name do
      if before_name.is_a?(Regexp)
        skip_names[file_path] ||= []
        if !skip_names[file_path].include?(node.to_source) && node.message.to_s =~ before_name
          replace :message, with: after_name.sub('{{attribute}}', Regexp.last_match(1))
        end
      else
        replace :message, with: after_name
      end
    end
  end

  # find callbacks and convert them
  helper_method :find_callbacks_and_convert do |callback_names, callback_changes|
    custom_callback_names = []

    # find callback like
    #
    #     after_save :invalidate_cache, if: :status_changed?
    with_node node_type: 'call_node',
              receiver: nil,
              name: { in: callback_names },
              arguments: { node_type: 'arguments_node', arguments: { first: { node_type: 'symbol_node' } } } do
      custom_callback_names << node.arguments.arguments.first.to_value
      callback_changes.each do |before_name, after_name|
        # convert ActiveRecord::Dirty api change
        #
        # after_save :invalidate_cache, if: :status_changed?
        with_node node_type: 'keyword_hash_node' do
          with_node node_type: 'symbol_node', to_value: { not_in: %i[if unless] } do
            custom_callback_names << node.to_value
          end

          with_node node_type: 'symbol_node', to_value: before_name do
            if before_name.is_a?(Regexp)
              skip_names[file_path] ||= []
              if !skip_names[file_path].include?(node.to_value.to_s) && node.to_value =~ before_name
                replace_with ":#{after_name.sub('{{attribute}}', Regexp.last_match(1))}"
              end
            else
              replace_with after_name
            end
          end
        end
        convert_send_dirty_api_change(before_name, after_name)
      end
    end

    # find callback like
    #
    #     before_save do
    #       if status_chagned?
    #       end
    #     end
    with_node node_type: 'call_node', receiver: nil, name: { in: callback_names }, block: { node_type: 'block_node' } do
      callback_changes.each do |before_name, after_name|
        convert_send_dirty_api_change(before_name, after_name)
      end
    end

    # find callback method like
    #
    #     after_save :invalidate_cache
    #     def invalidate_cache
    #     end
    with_node node_type: 'def_node', name: { in: callback_names } do
      callback_changes.each do |before_name, after_name|
        convert_send_dirty_api_change(before_name, after_name)
      end

      with_node node_type: 'call_node', receiver: nil do
        custom_callback_names << node.name
      end
    end

    # find all custom callback methods
    while custom_callback_names.present?
      temp_callback_names = []
      with_node node_type: 'def_node', name: { in: custom_callback_names } do
        callback_changes.each do |before_name, after_name|
          convert_send_dirty_api_change(before_name, after_name)
        end

        with_node node_type: 'call_node', receiver: nil do
          temp_callback_names << node.name
        end
      end
      custom_callback_names = temp_callback_names
    end
  end

  # round one: find all possible skip names
  within_files Synvert::RAILS_MODEL_FILES + Synvert::RAILS_OBSERVER_FILES do
    with_node node_type: 'def_node' do
      skip_names[file_path] ||= []
      skip_names[file_path] << node.name.to_s
    end
  end

  # round two: find callbacks and do convert
  within_files Synvert::RAILS_MODEL_FILES + Synvert::RAILS_OBSERVER_FILES do
    find_callbacks_and_convert(before_callback_names, before_callback_changes)
    find_callbacks_and_convert(after_callback_names, after_callback_changes)
  end
end
