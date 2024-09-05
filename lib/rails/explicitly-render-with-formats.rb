# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'explicitly-render-with-formats' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It calls render with formats explicitly.

    ```ruby
    render template: 'index.json'
    ```

    =>

    ```ruby
    render template: 'index', foramts: [:json]
    ```
  EOS

  if_gem 'active_support', '>= 7.0'

  within_files Synvert::RAILS_CONTROLLER_FILES do
    find_node ".call_node[receiver=nil][name=render][arguments=.arguments_node[arguments.size=1][arguments.0=.keyword_hash_node]]" do
      template_value = node.arguments.arguments.first.template_value.to_value
      if template_value&.split('.')&.size == 2
        replace 'arguments.arguments.0.template_value', with: "'#{template_value.split('.').first}'"
        insert "formats: [:#{template_value.split('.').last}]", at: 'end', to: 'arguments.arguments.0', and_comma: true
      end
    end
  end
end
