# frozen_string_literal: true

Synvert::Rewriter.new 'rspec', 'new_config_options' do
  description <<~EOS
    It converts rspec configuration options.

    1. it removes `config.treat_symbols_as_metadata_keys_with_true_values = true`

    2. it converts

    ```ruby
    RSpec.configure do |c|
      c.backtrace_clean_patterns
      c.backtrace_clean_patterns = [/lib\/something/]
      c.color_enabled = true

      c.out
      c.out = File.open('output.txt', 'w')
      c.output
      c.output = File.open('output.txt', 'w')

      c.backtrace_cleaner
      c.color?(output)
      c.filename_pattern
      c.filename_pattern = '**/*_test.rb'
      c.warnings
    end
    ```

    =>

    ```ruby
    RSpec.configure do |c|
      c.backtrace_exclusion_patterns
      c.backtrace_exclusion_patterns = [/lib\/something/]
      c.color = true

      c.output_stream
      c.output_stream = File.open('output.txt', 'w')
      c.output_stream
      c.output_stream = File.open('output.txt', 'w')

      c.backtrace_formatter
      c.color_enabled?(output)
      c.pattern
      c.pattern = '**/*_test.rb'
      c.warnings?
    end
    ```
  EOS

  if_gem 'rspec-core', '>= 2.99'

  within_file 'spec/spec_helper.rb' do
    within_node type: 'block', caller: { type: 'send', receiver: 'RSpec', message: 'configure' } do
      config_name = node.arguments.first.to_source

      # remove config.treat_symbols_as_metadata_keys_with_true_values = true
      with_node type: 'send', receiver: config_name, message: 'treat_symbols_as_metadata_keys_with_true_values=' do
        remove
      end

      # RSpec.configure do |c|
      #   c.backtrace_clean_patterns
      #   c.out
      #   c.output
      #   c.backtrace_cleaner
      #   c.filename_pattern
      #   c.warnings
      # end
      # =>
      # RSpec.configure do |c|
      #   c.backtrace_exclusion_patterns
      #   c.output_stream
      #   c.output_stream
      #   c.backtrace_formatter
      #   c.pattern
      #   c.warnings?
      # end
      {
        'backtrace_clean_patterns' => 'backtrace_exclusion_patterns',
        'out' => 'output_stream',
        'output' => 'output_stream',
        'backtrace_cleaner' => 'backtrace_formatter',
        'filename_pattern' => 'pattern',
        'warnings' => 'warnings?'
      }.each do |old_message, new_message|
        with_node type: 'send', receiver: config_name, message: old_message do
          replace :message, with: new_message
        end
      end

      # RSpec.configure do |c|
      #   c.backtrace_clean_patterns = [/lib\/something/]
      #   c.color_enabled = true
      #   c.out = File.open('output.txt', 'w')
      #   c.output = File.open('output.txt', 'w')
      #   c.filename_pattern = '**/*_test.rb'
      # end
      # =>
      # RSpec.configure do |c|
      #   c.backtrace_exclusion_patterns = [/lib\/something/]
      #   c.color = true
      #   c.output_stream = File.open('output.txt', 'w')
      #   c.output_stream = File.open('output.txt', 'w')
      #   c.pattern = '**/*_test.rb'
      # end
      {
        'backtrace_clean_patterns=' => 'backtrace_exclusion_patterns =',
        'color_enabled=' => 'color =',
        'out=' => 'output_stream =',
        'output=' => 'output_stream =',
        'filename_pattern=' => 'pattern ='
      }.each do |old_message, new_message|
        with_node type: 'send', receiver: config_name, message: old_message do
          replace :message, with: new_message
        end
      end

      # RSpec.configure do |c|
      #   c.color?(output)
      # end
      # =>
      # RSpec.configure do |c|
      #   c.color_enabled?(output)
      # end
      with_node type: 'send', receiver: config_name, message: 'color?' do
        replace :message, with: 'color_enabled?'
      end
    end
  end
end
