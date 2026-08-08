# frozen_string_literal: true

Synvert::Helper.new 'rails/parse' do |_options|
  configure(parser: Synvert::PRISM_PARSER)

  MODEL_ASSOCIATIONS = %i[belongs_to has_one has_many has_and_belongs_to_many].freeze

  definitions = RailsDefinitions.new

  # Set number_of_workers to 1 to skip parallel.
  with_configurations(number_of_workers: 1) do
    within_file 'db/schema.rb' do
      within_node node_type: 'call_node', name: 'create_table'  do
        table_name = node.arguments.arguments.first.to_value
        with_node node_type: 'call_node', receiver: 't', message: { not: 'index' } do
          column_name = node.arguments.arguments.first.to_value
          column_type = node.name.to_s
          definitions.add_table_column(table_name, column_name, column_type)
        end
        with_node node_type: 'call_node', receiver: 't', message: 'index' do
          index_columns = node.arguments.arguments.first.to_value
          index_name = node.arguments.arguments.second.name_value.to_value
          definitions.add_table_index(table_name, index_name, index_columns)
        end
      end
    end

    within_files Synvert::RAILS_MODEL_FILES do
      add_callback :class_node, at: 'start' do |node|
        model_name = node.full_name

        add_callback :call_node, at: 'start' do |node|
          if node.receiver.nil? && MODEL_ASSOCIATIONS.include?(node.name)
            association_name = node.arguments.arguments.first.to_value
            association_type = node.name.to_s
            options = {}
            if node.arguments.arguments.length > 1 && node.arguments.arguments.last.is_a?(Prism::KeywordHashNode)
              option_elements = node.arguments.arguments.last.elements
              %i[foreign_key foreign_type polymorphic].each do |option_key|
                option_element = option_elements.find { |element| element.key.value == option_key.to_s }
                options[option_key] = option_element.value.to_value if option_element
              end
            end
            definitions.add_model_association(model_name, association_name.to_s, association_type, **options)
          end
        end
      end
    end
  end

  definitions
end

class RailsDefinitions
  attr_reader :table_definitions, :model_definitions

  delegate :add_table_column, :add_table_index, :find_table_definition_by_table_name, to: :@table_definitions
  delegate :add_model_association, to: :@model_definitions

  def initialize
    @table_definitions = TableDefinitions.new
    @model_definitions = ModelDefinitions.new
  end
end

class TableDefinitions
  include Enumerable

  delegate :each, to: :@table_definitions

  def initialize
    @table_definitions = []
  end

  def add_table_column(table_name, column_name, column_type)
    table_definition = find_or_create_table_definition(table_name)
    table_definition.add_column(column_name, column_type)
  end

  def add_table_index(table_name, index_name, column_names)
    table_definition = find_or_create_table_definition(table_name)
    table_definition.add_index(index_name, column_names)
  end

  def find_or_create_table_definition(table_name)
    table_definition = find_table_definition_by_table_name(table_name)
    return table_definition if table_definition

    table_definition = TableDefinition.new(name: table_name)
    @table_definitions << table_definition
    return table_definition
  end

  def find_table_definition_by_table_name(table_name)
    @table_definitions.find { |table| table.name == table_name  }
  end

  def to_h
    @table_definitions.map(&:to_h)
  end
end

class TableDefinition
  attr_reader :name, :columns

  def initialize(name:)
    @name = name
    @columns = []
    @indices = []
  end

  def add_column(name, type)
    @columns << ColumnDefinition.new(name: name, type: type)
  end

  def add_index(name, columns)
    @indices << IndexDefinition.new(name: name, columns: columns)
  end

  def find_index_definition_by_column_names(column_names)
    @indices.find { |index_definition| index_definition.columns == column_names  }
  end

  def get_column_names
    @columns.map(&:name)
  end

  def to_h
    {
      name: @name,
      columns: @columns.map(&:to_h),
      indices: @indices.map(&:to_h)
    }
  end
end

class ColumnDefinition
  attr_reader :name

  def initialize(name:, type:)
    @name = name
    @type = type
  end

  def to_h
    { name: @name, type: @type }
  end
end

class IndexDefinition
  attr_reader :columns

  def initialize(name:, columns:)
    @name = name
    @columns = columns
  end

  def to_h
    { name: @name, columns: @columns }
  end
end

class ModelDefinitions
  include Enumerable

  delegate :each, to: :@model_definitions

  def initialize
    @model_definitions = []
  end

  def add_model_association(model_name, association_name, association_type, **association_options)
    model_definition = find_or_create_model_definition(model_name)
    model_definition.add_association(association_name, association_type, **association_options)
  end

  def find_or_create_model_definition(model_name)
    model_definition = @model_definitions.find { |model_definition| model_definition.name == model_name  }
    return model_definition if model_definition

    model_definition = ModelDefinition.new(name: model_name)
    @model_definitions << model_definition
    return model_definition
  end

  def to_h
    @model_definitions.map(&:to_h)
  end
end

class ModelDefinition
  attr_reader :name, :associations

  def initialize(name:)
    @name = name
    @associations = []
  end

  def add_association(name, type, **options)
    @associations << AssociationDefinition.new(name: name, type: type, **options)
  end

  def to_h
    { name: name, associations: @associations.map(&:to_h) }
  end
end

class AssociationDefinition
  attr_reader :name, :type, :options

  def initialize(name:, type:, **options)
    @name = name
    @type = type
    @options = options
  end

  def to_h
    { name: @name, type: @type, options: @options }
  end
end
