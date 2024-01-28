# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_3_0_to_3_1' do
  configure(parser: Synvert::PARSER_PARSER)

  description 'It converts rails from 3.0 to 3.1.'

  add_snippet 'rails', 'convert_configs_3_0_to_3_1'
  add_snippet 'rails', 'use_migrations_instance_methods'
end
