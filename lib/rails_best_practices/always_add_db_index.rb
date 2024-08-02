# frozen_string_literal: true

Synvert::Rewriter.new 'rails_best_practices', 'always_add_db_index' do
  description <<~EOS
    Review db/schema.rb file to make sure every reference key has a database index.

    See the best practice details here https://rails-bestpractices.com/posts/2010/07/24/always-add-db-index/
  EOS

  definitions = call_helper 'rails/parse'

  configure(parser: Synvert::PRISM_PARSER)

  within_files 'db/schema.rb' do
    definitions.model_definitions.each do |model_definition|
      # TODO: check self.table_name =
      table_name = model_definition.name.tableize
      table_definition = definitions.find_table_definition_by_table_name(table_name)

      model_definition.associations.select { |association_definition|
        association_definition.type == 'belongs_to'
      }
.each do |association_definition|
        if association_definition.options[:polymorphic]
          foreign_key = association_definition.options[:foreign_key]&.to_s || association_definition.name.foreign_key
          foreign_type = association_definition.options[:foreign_type]&.to_s || (association_definition.name.demodulize + '_type').underscore
          unless table_definition.find_index_definition_by_column_names([foreign_type, foreign_key])
            find_node ".call_node[receiver=nil][name=create_table][arguments!=nil][arguments.arguments.first='#{table_name}']
                       .call_node[receiver=t][arguments!=nil][arguments.arguments.first='#{foreign_key}']" do
              warn "always add db index #{table_name} => [\"#{foreign_type}\", \"#{foreign_key}\"]"
            end
          end
        else
          foreign_key = association_definition.options[:foreign_key]&.to_s || association_definition.name.foreign_key
          unless table_definition.find_index_definition_by_column_names([foreign_key])
            find_node ".call_node[receiver=nil][name=create_table][arguments!=nil][arguments.arguments.first='#{table_name}']
                       .call_node[receiver=t][arguments!=nil][arguments.arguments.first='#{foreign_key}']" do
              warn "always add db index #{table_name} => [\"#{foreign_key}\"]"
            end
          end
        end
      end
    end
  end
end
