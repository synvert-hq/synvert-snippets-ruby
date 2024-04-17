# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_4_2_to_5_0' do
  description 'It upgrades rails 4.2 to 5.0.'

  add_snippet 'rails', 'add_active_record_migration_rails_version'
  add_snippet 'rails', 'convert_configs_4_2_to_5_0'
  add_snippet 'rails', 'convert_constants_4_2_to_5_0'
  add_snippet 'rails', 'convert_env_to_request_env'
  add_snippet 'rails', 'convert_head_response'
  add_snippet 'rails', 'convert_render_text_to_render_plain'
  add_snippet 'rails', 'convert_test_request_methods_4_2_to_5_0'
  add_snippet 'rails', 'convert_to_response_parsed_body'
  add_snippet 'rails', 'add_application_record'
  add_snippet 'rails', 'add_application_job'
  add_snippet 'rails', 'add_application_mailer'
  add_snippet 'rails', 'convert_after_commit'
  add_snippet 'rails', 'convert_model_errors_add'
end
