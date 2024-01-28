# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_2_3_to_3_0' do
  configure(parser: Synvert::PARSER_PARSER)

  description 'It converts rails from 2.3 to 3.0.'

  add_snippet 'rails', 'convert_configs_2_3_to_3_0'
  add_snippet 'rails', 'convert_dynamic_finders_for_rails_3'
  add_snippet 'rails', 'convert_mailers_2_3_to_3_0'
  add_snippet 'rails', 'convert_models_2_3_to_3_0'
  add_snippet 'rails', 'convert_rails_env'
  add_snippet 'rails', 'convert_rails_root'
  add_snippet 'rails', 'convert_rails_logger'
  add_snippet 'rails', 'convert_routes_2_3_to_3_0'
  add_snippet 'rails', 'convert_views_2_3_to_3_0'
end
