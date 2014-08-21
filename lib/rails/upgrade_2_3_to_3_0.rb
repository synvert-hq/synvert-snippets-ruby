Synvert::Rewriter.new 'rails', 'upgrade_2_3_to_3_0' do
  description <<-EOF
It converts rails from 2.3 to 3.0, it calls

  convert_mailers_2_3_to_3_0
  convert_models_2_3_to_3_0
  convert_rails_env
  convert_rails_root
  convert_rails_logger
  convert_routes_2_3_to_3_0
  convert_views_2_3_to_3_0

snippets.
  EOF

  add_snippet 'rails', 'convert_mailers_2_3_to_3_0'
  add_snippet 'rails', 'convert_models_2_3_to_3_0'
  add_snippet 'rails', 'convert_rails_env'
  add_snippet 'rails', 'convert_rails_root'
  add_snippet 'rails', 'convert_rails_logger'
  add_snippet 'rails', 'convert_routes_2_3_to_3_0'
  add_snippet 'rails', 'convert_views_2_3_to_3_0'

  filter_parameters = []
  within_file 'app/controllers/application_controller.rb' do
    with_node type: 'send', message: 'filter_parameter_logging' do
      filter_parameters = node.arguments.map(&:to_source)
      remove
    end
  end

  within_file 'config/application.rb' do
    with_node type: 'class', parent_class: 'Rails::Application' do
      append "config.filter_parameters += [#{filter_parameters.join(', ')}]"
    end
  end
end
