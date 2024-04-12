# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'deprecate_active_record_migration_check_pending' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It removes `ActiveRecord::Migration.check_pending!` in `test/test_helper.rb`
  EOS

  if_gem 'rails', '>= 4.1'

  within_file 'test/test_helper.rb' do
    # ActiveRecord::Migration.check_pending! => require 'test_help'
    with_node node_type: 'call_node', receiver: 'ActiveRecord::Migration', name: 'check_pending!' do
      remove
    end
  end
end
