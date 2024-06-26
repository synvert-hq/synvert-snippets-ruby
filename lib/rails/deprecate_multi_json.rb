# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'deprecate_multi_json' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It replaces multi_json with json.

    1. replace `MultiJson.dump` with `obj.to_json`

    2. replace `MultiJson.load` with `JSON.parse(str)`
  EOS

  if_gem 'rails', '>= 4.1'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # MultiJson.dump(obj) => obj.to_json
    with_node node_type: 'call_node', receiver: 'MultiJson', name: 'dump' do
      replace_with '{{arguments.arguments}}.to_json'
    end

    # MultiJson.load(str) => JSON.parse(str)
    with_node node_type: 'call_node', receiver: 'MultiJson', name: 'load' do
      replace_with 'JSON.parse {{arguments.arguments}}'
    end
  end
end
