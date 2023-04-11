# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'pp'
require 'synvert/core'
require 'fakefs/spec_helpers'

Dir[File.expand_path(File.join(File.dirname(__FILE__), 'support/*.rb'))].each { |f| require f }

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true

  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'

  config.before do
    allow_any_instance_of(Synvert::Core::Rewriter::GemSpec).to receive(:match?).and_return(true)
  end
  config.expose_dsl_globally = false
end
