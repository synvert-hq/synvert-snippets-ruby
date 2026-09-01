# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'serialize_use_keyword_arguments' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts Active Record serialize calls to use keyword arguments in Rails 7.1+.

    ```ruby
    serialize :preferences, Hash
    serialize :metadata, JSON
    serialize :settings, Array
    serialize :preferences, Hash, default: {}
    serialize :metadata, JSON, default: {}
    serialize :payload, CustomCoder
    ```

    =>

    ```ruby
    serialize :preferences, type: Hash, coder: YAML
    serialize :metadata, coder: JSON
    serialize :settings, type: Array, coder: YAML
    serialize :preferences, type: Hash, coder: YAML, default: {}
    serialize :metadata, coder: JSON, default: {}
    serialize :payload, coder: CustomCoder
    ```
  EOS

  if_gem 'activerecord', '>= 7.1'

  # These built-in constants are types in the legacy API, not coders. Unknown
  # constants are kept as coders because custom coder classes cannot be
  # distinguished from custom type classes from source alone.
  serialize_types = %w[
    Array
    Hash
    Object
    String
    Integer
    Float
    Numeric
    Rational
    Complex
    Symbol
    Date
    Time
  ]

  within_files Synvert::RAILS_MODEL_FILES do
    with_node node_type: 'call_node',
              receiver: nil,
              name: 'serialize',
              arguments: {
                node_type: 'arguments_node',
                arguments: { size: { gt: 1 }, '1': { node_type: { not: 'keyword_hash_node' } } }
              } do
      serialized_type = node.arguments.arguments[1].to_source
      serialized_type_name = serialized_type.sub(/\A::/, '')
      if serialize_types.include?(serialized_type_name)
        replace 'arguments.arguments.1', with: "type: #{serialized_type}, coder: YAML"
      else
        replace 'arguments.arguments.1', with: "coder: #{serialized_type}"
      end
    end
  end
end
