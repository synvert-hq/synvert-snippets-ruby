# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_3_2_to_4_0' do
  description 'It upgrades rails from 3.2 to 4.0.'

  add_snippet 'rails', 'convert_configs_3_2_to_4_0'
  add_snippet 'rails', 'convert_constants_3_2_to_4_0'
  add_snippet 'rails', 'convert_models_3_2_to_4_0'
  add_snippet 'rails', 'convert_routes_3_2_to_4_0'
  add_snippet 'rails', 'convert_views_3_2_to_4_0'
  add_snippet 'rails', 'convert_dynamic_finders_for_rails_4'
  add_snippet 'rails', 'strong_parameters'
  add_snippet 'rails', 'convert_controller_filter_to_action'
  add_snippet 'rails', 'convert_model_lambda_scope'
end
