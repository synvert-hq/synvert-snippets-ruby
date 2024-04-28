# frozen_string_literal: true

require 'spec_helper'
require 'helpers/set_rails_load_defaults'

RSpec.describe 'rails/set_load_defaults helper', fakefs: true do
  it 'sets config.load_defaults' do
    rewriter =
      Synvert::Rewriter.new 'test', 'set_rails_load_defaults_helper' do
        call_helper 'rails/set_load_defaults', rails_version: '6.0'
      end

    file_path = 'config/application.rb'
    FileUtils.mkdir_p(File.dirname(file_path))
    File.write(file_path, <<~EOF)
      module Synvert
        class Application < Rails::Application
          config.load_defaults 5.2
        end
      end
    EOF

    rewriter.process

    expect(File.read(file_path)).to eq <<~EOF
      module Synvert
        class Application < Rails::Application
          config.load_defaults 6.0
        end
      end
    EOF
  end
end
