# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_2_3_to_3_0' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts rails configs from 2.3 to 3.0.

    It removes `filter_parameter_logging :password` from `app/controllers/application_controller.rb`,
    and adds `config.filter_parameters += [:password]` in `config/application.rb`.
  EOS

  if_gem 'rails', '~> 3.0.0'

  filter_parameters = []
  within_file 'app/controllers/application_controller.rb' do
    with_node node_type: 'call_node', name: 'filter_parameter_logging' do
      filter_parameters = node.arguments.arguments.map(&:to_source)
      remove
    end
  end

  if filter_parameters.present?
    within_file 'config/application.rb' do
      with_node node_type: 'class_node', superclass: 'Rails::Application' do
        unless_exist_node node_type: 'call_node', receiver: 'config', name: 'filter_parameters' do
          append "config.filter_parameters += [#{filter_parameters.join(', ')}]"
        end
      end
    end
  end
end
