# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_4_0_to_4_1' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It upgrades rails from 4.0 to 4.1.

    Warn return within inline callback blocks `before_save { return false }`
  EOS

  add_snippet 'rails', 'convert_configs_4_0_to_4_1'
  add_snippet 'rails', 'deprecate_ar_migration_check_pending'
  add_snippet 'rails', 'deprecate_multi_json'

  if_gem 'rails', '>= 4.1'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    [/before_/, /after_/].each do |message_regex|
      # Warn if finding return in before_* or after_* callbacks
      within_node node_type: 'block', caller: { node_type: 'send', message: message_regex } do
        with_node node_type: 'return' do
          warn 'Using a return statement in an inline callback block causes a LocalJumpError to be raised when the callback is executed.'
        end
      end
    end
  end
end
