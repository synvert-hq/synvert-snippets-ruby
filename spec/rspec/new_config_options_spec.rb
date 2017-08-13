require 'spec_helper'

RSpec.describe 'RSpec use new config options' do
  let!(:rewriter_path) { File.join(File.dirname(__FILE__), '../../lib/rspec/new_config_options.rb') }
  let!(:rewriter) { eval(File.read(rewriter_path)) }

  describe 'with fakefs', fakefs: true do
    let(:spec_helper_content) { '
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.backtrace_clean_patterns
  config.backtrace_clean_patterns = [/lib\/something/]
  config.color_enabled = true

  config.out
  config.out = File.open("output.txt", "w")
  config.output
  config.output = File.open("output.txt", "w")

  config.backtrace_cleaner
  config.color?(output)
  config.filename_pattern
  config.filename_pattern = "**\/*_test.rb"
  config.warnings
end
    '}
    let(:spec_helper_rewritten_content) { '
RSpec.configure do |config|

  config.backtrace_exclusion_patterns
  config.backtrace_exclusion_patterns = [/lib\/something/]
  config.color = true

  config.output_stream
  config.output_stream = File.open("output.txt", "w")
  config.output_stream
  config.output_stream = File.open("output.txt", "w")

  config.backtrace_formatter
  config.color_enabled?(output)
  config.pattern
  config.pattern = "**\/*_test.rb"
  config.warnings?
end
    '}

    it 'converts' do
      FileUtils.mkdir 'spec'
      File.write 'spec/spec_helper.rb', spec_helper_content
      rewriter.process
      expect(File.read 'spec/spec_helper.rb').to eq spec_helper_rewritten_content
    end
  end
end
