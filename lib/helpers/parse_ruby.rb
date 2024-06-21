# frozen_string_literal: true

Synvert::Helper.new 'ruby/parse' do |options|
  configure(parser: Synvert::PRISM_PARSER)

  # Set number_of_workers to 1 to skip parallel.
  with_configurations(number_of_workers: 1) do
    definitions = { modules: [], classes: [] }
    current_context = definitions
    context_stack = []

    within_file Synvert::ALL_RUBY_FILES do
      add_callback :module_node, at: 'start' do |node|
        name = node.constant_path.to_source
        existing_module = current_context[:modules].find { |mod| mod[:name] == name }
        if existing_module
          new_context = existing_module
        else
          new_context = { name: name, modules: [], classes: [], methods: [], static_methods: [], constants: [] }
          current_context[:modules] << new_context
        end

        context_stack.push(current_context)
        current_context = new_context
      end

      add_callback :module_node, at: 'end' do |node|
        current_context = context_stack.pop
      end

      add_callback :class_node, at: 'start' do |node|
        name = node.constant_path.to_source
        superclass = node.superclass&.to_source
        existing_class = current_context[:classes].find { |klass| klass[:name] == name }
        if existing_class
          new_context = existing_class
        else
          new_context = {
            name: name,
            superclass: superclass,
            modules: [],
            classes: [],
            methods: [],
            static_methods: [],
            singleton: {},
            constants: [],
            included_modules: []
          }
          current_context[:classes] << new_context
        end

        context_stack.push(current_context)
        current_context = new_context
      end

      add_callback :class_node, at: 'end' do |node|
        current_context = context_stack.pop
      end

      add_callback :singleton_class_node, at: 'start' do |node|
        existing_singleton = current_context[:singleton]
        if !existing_singleton.empty?
          new_context = existing_singleton
        else
          new_context = { methods: [] }
          current_context[:singleton] = new_context
        end

        context_stack.push(current_context)
        current_context = new_context
      end

      add_callback :singleton_class_node, at: 'end' do |node|
        current_context = context_stack.pop
      end

      add_callback :constant_write_node do |node|
        current_context[:constants] << { name: node.name.to_s }
      end

      add_callback :call_node, at: 'start' do |node|
        if node.receiver.nil? && node.name == :include
          current_context[:included_modules] << node.arguments.arguments.first.to_source
        end
      end

      add_callback :def_node, at: 'start' do |node|
        name = node.name.to_s

        new_context = { name: name }
        if node.receiver.nil?
          current_context[:methods] << new_context
        else
          current_context[:static_methods] << new_context
        end

        context_stack.push(current_context)
        current_context = new_context
      end

      add_callback :def_node, at: 'end' do |node|
        current_context = context_stack.pop
      end
    end

    def find_class(name, definitions)
      definitions[:classes].each do |klass|
        return klass if klass[:name] == name

        found = find_class(name, klass)
        return found if found
      end

      definitions[:modules].each do |mod|
        found = find_class(name, mod)
        return found if found
      end

      nil
    end

    def add_ancestors(definitions)
      definitions[:classes].each do |klass|
        ancestors = []
        superclass = klass[:superclass]
        while superclass
          ancestors << superclass
          superclass_class = find_class(superclass, definitions)
          if superclass_class
            ancestors.concat(superclass_class[:included_modules]) if superclass_class[:included_modules]
            superclass = superclass_class[:superclass]
          else
            superclass = nil
          end
        end
        ancestors.concat(klass[:included_modules]) if klass[:included_modules]
        klass[:ancestors] = ancestors

        add_ancestors(klass)
      end

      definitions[:modules].each do |mod|
        add_ancestors(mod)
      end
    end

    add_ancestors(definitions)

    save_data :ruby_definitions, definitions
  end
end
