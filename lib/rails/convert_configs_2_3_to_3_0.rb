# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_2_3_to_3_0' do
  configure(parser: Synvert::PARSER_PARSER)

  description 'It converts rails configs from 2.3 to 3.0.'

  if_gem 'rails', '~> 3.0.0'

  filter_parameters = []
  within_file 'app/controllers/application_controller.rb' do
    with_node node_type: 'send', message: 'filter_parameter_logging' do
      filter_parameters = node.arguments.map(&:to_source)
      remove
    end
  end

  within_file 'config/application.rb' do
    with_node node_type: 'class', parent_class: 'Rails::Application' do
      unless_exist_node node_type: 'send', receiver: 'config', message: 'filter_parameters' do
        append "config.filter_parameters += [#{filter_parameters.join(', ')}]"
      end
    end
  end
end
