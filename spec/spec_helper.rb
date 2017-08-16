$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'synvert/core'
require 'fakefs/spec_helpers'

require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true

  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'

  config.before do
    Synvert::Core::Configuration.instance.set :skip_files, []
    Synvert::Core::Configuration.instance.set :path, '.'
    Synvert::Core::Rewriter::Instance.reset
    allow_any_instance_of(Synvert::Core::Rewriter::GemSpec).to receive(:match?).and_return(true)
  end
  config.expose_dsl_globally = false

  def verifying_content_change(filename, before_content, after_content)
    FileUtils.mkdir_p(File.dirname(filename))
    File.write filename, before_content
    yield
    expect(File.read(filename)).to eq after_content
  end
end
