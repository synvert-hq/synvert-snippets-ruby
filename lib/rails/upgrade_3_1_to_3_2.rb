Synvert::Rewriter.new 'rails', 'upgrade_3_1_to_3_2' do
  description <<-EOF
It upgrades rails from 3.1 to 3.2.

1. it insrts new configs in config/environments/development.rb.

    config.active_record.mass_assignment_sanitizer = :strict
    config.active_record.auto_explain_threshold_in_seconds = 0.5

2. it insert new configs in config/environments/test.rb.

    config.active_record.mass_assignment_sanitizer = :strict

3. deprecations

    set_table_name "project" => self.table_name = "project"
    set_inheritance_column = "type" => self.inheritance_column = "type"
    set_sequence_name = "seq" => self.sequence_name = "seq"
    set_primary_key = "id" => self.primary_key = "id"
    set_locking_column = "lock" => self.locking_column = "lock"

    ActionController::UnknownAction => AbstractController::ActionNotFound
    ActionController::DoubleRenderError => AbstractController::DoubleRenderError
  EOF

  if_gem 'rails', {gte: '3.1.0'}

  within_file 'config/environments/development.rb' do
    # insert config.active_record.auto_explain_threshold_in_seconds = 0.5
    unless_exist_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'active_record'}, message: 'auto_explain_threshold_in_seconds=' do
      insert 'config.active_record.auto_explain_threshold_in_seconds = 0.5'
    end
  end

  within_files "config/environments/{development,test}.rb" do
    # insert config.active_record.mass_assignment_sanitizer = :strict
    unless_exist_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'active_record'}, message: 'mass_assignment_sanitizer=' do
      insert 'config.active_record.mass_assignment_sanitizer = :strict'
    end
  end

  within_files 'app/models/**/*.rb' do
    # set_table_name "project" => self.table_name = "project"
    # set_inheritance_column = "type" => self.inheritance_column = "type"
    # set_sequence_name = "seq" => self.sequence_name = "seq"
    # set_primary_key = "id" => self.primary_key = "id"
    # set_locking_column = "lock" => self.locking_column = "lock"
    %w(set_table_name set_inheritance_column set_sequence_name set_primary_key set_locking_column).each do |message|
      with_node type: 'send', message: message do
        new_message = message.sub('set_', '')
        replace_with "self.#{new_message} = {{arguments}}"
      end
    end
  end

  within_files 'app/controllers/**/*.rb' do
    # ActionController::UnknownAction => AbstractController::ActionNotFound
    # ActionController::DoubleRenderError => AbstractController::DoubleRenderError
    {'ActionController::UnknownAction' => 'AbstractController::ActionNotFound',
     'ActionController::DoubleRenderError' => 'AbstractController::DoubleRenderError'}.each do |old_const, new_const|
      with_node type: 'const', to_source: old_const do
        replace_with new_const
      end
    end
  end

  within_files 'vendor/plugins' do
    warn 'Rails::Plugin is deprecated and will be removed in Rails 4.0. Instead of adding plugins to vendor/plugins use gems or bundler with path or git dependencies.'
  end

  todo <<-EOF
Make the following changes to your Gemfile.

    group :assets do
      gem 'sass-rails',   '~> 3.2.3'
      gem 'coffee-rails', '~> 3.2.1'
      gem 'uglifier',     '>= 1.0.3'
    end
  EOF
end
