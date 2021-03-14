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
    /(\w+)_was$/ =>	'{{attribute}}_in_database',
    'changes' => 'changes_to_save',
    'changed?' => 'has_changes_to_save?',
    'changed' => 'changed_attribute_names_to_save',
    'changed_attributes' => 'attributes_in_database'
  }

  AFTER_CALLBACK_CHANGES = {
    /(\w+)_changed\?$/ => 'saved_change_to_{{attribute}}?',
    /(\w+)_change$/ => 'saved_change_to_{{attribute}}',
    /(\w+)_was$/ =>	'{{attribute}}_before_last_save',
    'changes' => 'saved_changes',
    'changed?' => 'saved_changes?',
    'changed' => 'saved_changes.keys',
    'changed_attributes' => 'saved_changes.transform_values(&:first)'
  }

  helper_method :convert_callback do |before_name, after_name|
    with_node type: 'sym', to_value: before_name do
      if before_name.is_a?(Regexp)
        node.to_value =~ before_name
        replace_with ":#{after_name.sub('{{attribute}}', Regexp.last_match(1))}"
      else
        replace_with after_name
      end
    end
    with_node type: 'send', receiver: nil, message: before_name do
      if before_name.is_a?(Regexp)
        node.message.to_s =~ before_name
        replace_with after_name.sub('{{attribute}}', Regexp.last_match(1))
      else
        replace_with after_name
      end
    end
  end

  within_files 'app/models/**/*.rb' do
    before_callback_names = []

    %i[before_create before_update before_save].each do |callback_name|
      with_node type: 'send', receiver: nil, message: callback_name do
        before_callback_names << node.arguments[0].to_value
        if node.arguments[1] && node.arguments[1].type == :hash
          goto_node node.arguments[1] do
            BEFORE_CALLBACK_CHANGES.each do |before_name, after_name|
              convert_callback(before_name, after_name)
            end
          end
        end
      end
    end

    with_node type: 'def' do
      if before_callback_names.include?(node.name)
        BEFORE_CALLBACK_CHANGES.each do |before_name, after_name|
          convert_callback(before_name, after_name)
        end
      end
    end

    after_callback_names = []

    %i[after_create after_update after_save after_commit after_create_commit after_update_commit after_save_commit].each do |callback_name|
      with_node type: 'send', receiver: nil, message: callback_name do
        after_callback_names << node.arguments[0].to_value
        if node.arguments[1] && node.arguments[1].type == :hash
          goto_node node.arguments[1] do
            AFTER_CALLBACK_CHANGES.each do |before_name, after_name|
              convert_callback(before_name, after_name)
            end
          end
        end
      end
    end

    with_node type: 'def' do
      if after_callback_names.include?(node.name)
        AFTER_CALLBACK_CHANGES.each do |before_name, after_name|
          convert_callback(before_name, after_name)
        end
      end
    end
  end
end
