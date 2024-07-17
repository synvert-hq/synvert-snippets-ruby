# frozen_string_literal: true

# ruby/parser helper parses ruby files and saves the :ruby_definitions to data.
# The :ruby_definitions is an object of RubyDefinitions,
# which contains all the classes, modules, methods, constants, ancestors,
# and provides some methods, such as find_classes_by_ancestor.
Synvert::Helper.new 'ruby/parse' do |options|
  configure(parser: Synvert::PRISM_PARSER)

  # Set number_of_workers to 1 to skip parallel.
  with_configurations(number_of_workers: 1) do
    definitions = RubyDefinitions.new

    within_file Synvert::ALL_RUBY_FILES do
      add_callback :module_node, at: 'start' do |node|
        name = node.constant_path.to_source
        definitions.add_module(name)
      end

      add_callback :module_node, at: 'end' do |node|
        definitions.pop
      end

      add_callback :class_node, at: 'start' do |node|
        name = node.constant_path.to_source
        superclass = node.superclass&.to_source
        definitions.add_class(name, superclass)
      end

      add_callback :class_node, at: 'end' do |node|
        definitions.pop
      end

      add_callback :singleton_class_node, at: 'start' do |node|
        definitions.add_singleton
      end

      add_callback :singleton_class_node, at: 'end' do |node|
        definitions.pop
      end

      add_callback :constant_write_node do |node|
        definitions.add_constants(node.name.to_s)
      end

      add_callback :call_node, at: 'start' do |node|
        if node.receiver.nil? && node.name == :include && definitions.current_node_type == "class" && !node.arguments.nil? && %i[constant_read_node constant_path_node].include?(node.arguments.arguments.first.type)
          definitions.add_included_module(node.arguments.arguments.first.to_source)
        end
      end

      add_callback :call_node, at: 'start' do |node|
        # we can't handle the class_eval / included / class_methods
        if !node.receiver.nil? && %i[class_eval included class_methods].include?(node.name)
          throw(:abort)
        end
      end

      add_callback :def_node, at: 'start' do |node|
        # we can't handle `def self.inclueded` method
        if !node.receiver.nil? && node.name == :included
          throw(:abort)
        end
      end

      add_callback :def_node, at: 'start' do |node|
        throw(:abort) if definitions.is_root?

        name = node.name.to_s
        if node.receiver.nil?
          definitions.add_method(name)
        else
          definitions.add_static_method(name)
        end
      end

      add_callback :def_node, at: 'end' do |node|
        definitions.pop
      end
    end

    definitions.setup_ancestors
    save_data :ruby_definitions, definitions
  end
end

class RubyDefinitions
  attr_reader :node

  delegate :setup_ancestors, :find_class_by_full_name, :find_classes_by_ancestor, :to_h, to: :@root

  def initialize
    @root = RootDefinition.new
    @node = @root
  end

  def add_module(name)
    module_definition = @node.modules.find { |mod| mod.name == name }
    unless module_definition
      module_definition = ModuleDefinition.new(parent: @node, name: name)
      @node.modules.push(module_definition)
    end
    @node = module_definition
  end

  def add_class(name, superclass)
    class_definition = @node.classes.find { |klass| klass.name == name }
    unless class_definition
      class_definition = ClassDefinition.new(parent: @node, name: name, superclass: superclass)
      @node.classes.push(class_definition)
    end
    @node = class_definition
  end

  def add_singleton
    singleton_definition = @node.singleton
    unless singleton_definition
      singleton_definition = SingletonDefinition.new(parent: @node)
      @node.singleton = singleton_definition
    end
    @node = singleton_definition
  end

  def add_constants(name)
    @node.constants.push(name: name)
  end

  def add_included_module(name)
    @node.included_modules.push(name)
  end

  def add_method(name)
    method_definition = MethodDefinition.new(parent: @node, name: name)
    @node.methods.push(method_definition)
    @node = method_definition
  end

  def add_static_method(name)
    method_definition = MethodDefinition.new(parent: @node, name: name)
    @node.static_methods.push(method_definition)
    @node = method_definition
  end

  def pop
    @node = @node.parent
  end

  def is_root?
    @node.is_a?(RootDefinition)
  end

  def current_node_type
    @node.class.to_s.downcase.gsub('definition', '')
  end
end

class BaseDefinition
  def find_classes_by_ancestor(superclass)
    @classes.select { |klass| klass.ancestors.include?(superclass) } +
      @classes.flat_map { |klass| klass.find_classes_by_ancestor(superclass) } +
      @modules.flat_map { |mod| mod.find_classes_by_ancestor(superclass) }
  end

  def full_name
    names = [name]
    this = self
    while !this.parent.is_a?(RootDefinition)
      names.unshift(parent.name)
      this = this.parent
    end
    names.join('::')
  end

  def setup_ancestors
    classes.each do |klass|
      ancestors = []
      superclass = klass.superclass
      while superclass
        superclass_class = find_class_by_full_name(superclass)
        this = self
        while !superclass_class && !this.is_a?(RootDefinition)
          superclass_class = this.parent.find_class_by_full_name(superclass)
          this = this.parent
        end
        if superclass_class
          ancestors << superclass_class.full_name
          ancestors.concat(superclass_class.included_modules) if superclass_class.included_modules
          superclass = superclass_class.superclass
        else
          ancestors << superclass
          superclass = nil
        end
      end
      ancestors.concat(klass.included_modules) if klass.included_modules
      klass.ancestors = ancestors

      klass.setup_ancestors
    end

    modules.each do |mod|
      mod.setup_ancestors
    end
  end

  def find_class_by_full_name(full_name)
    names = full_name.split('::')
    if names.length > 1
      mod_name = names.shift
      modules.each do |mod|
        if mod.name == mod_name
          return mod.find_class_by_full_name(names.join('::'))
        end
      end
    else
      class_name = names.first
      classes.each do |klass|
        return klass if klass.name == class_name
      end
    end

    nil
  end
end

class RootDefinition < BaseDefinition
  attr_reader :modules, :classes, :constants, :methods

  def initialize
    @modules = []
    @classes = []
    @constants = []
    @methods = []
  end

  def to_h
    { modules: @modules.map(&:to_h), classes: @classes.map(&:to_h), constants: @constants, methods: @methods.map(&:to_h) }
  end
end

class ModuleDefinition < BaseDefinition
  attr_reader :parent, :name, :modules, :classes, :methods, :static_methods, :constants
  attr_accessor :singleton, :ancestors

  def initialize(parent:, name:)
    @parent = parent
    @name = name
    @modules = []
    @classes = []
    @methods = []
    @static_methods = []
    @constants = []
    @ancestors = []
  end

  def to_h
    {
      name: @name,
      modules: @modules.map(&:to_h),
      classes: @classes.map(&:to_h),
      methods: @methods.map(&:to_h),
      static_methods: @static_methods.map(&:to_h),
      constants: @constants,
      singleton: @singleton &.to_h,
      ancestors: @ancestors
    }
  end
end

class ClassDefinition < BaseDefinition
  attr_reader :parent, :name, :superclass, :modules, :classes, :methods, :static_methods, :constants, :included_modules
  attr_accessor :singleton, :ancestors

  def initialize(parent:, name:, superclass:)
    @parent = parent
    @name = name
    @superclass = superclass
    @modules = []
    @classes = []
    @methods = []
    @static_methods = []
    @constants = []
    @included_modules = []
    @ansestors = []
  end

  def to_h
    {
      name: @name,
      superclass: @superclass,
      modules: @modules.map(&:to_h),
      classes: @classes.map(&:to_h),
      methods: @methods.map(&:to_h),
      static_methods: @static_methods.map(&:to_h),
      constants: @constants,
      included_modules: @included_modules,
      singleton: @singleton&.to_h,
      ancestors: @ancestors
    }
  end
end

class SingletonDefinition
  attr_reader :parent, :methods, :constants
  attr_accessor :ancestors

  def initialize(parent:)
    @parent = parent
    @methods = []
    @constants = []
    @ancestors = []
  end

  def to_h
    {
      methods: @methods.map(&:to_h),
      constants: @constants,
      ancestors: @ancestors
    }
  end
end

class MethodDefinition
  attr_reader :parent, :name

  def initialize(parent:, name:)
    @parent = parent
    @name = name
  end

  def to_h
    { name: @name }
  end
end
