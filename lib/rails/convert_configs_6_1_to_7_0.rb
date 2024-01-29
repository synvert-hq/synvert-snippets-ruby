# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_6_1_to_7_0' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It converts rails configs from 6.1 to 7.0

    It sets `config.load_defaults 7.0` in config/application.rb.
  EOS

  if_gem 'rails', '>= 7.0'

  call_helper 'rails/set_load_defaults', rails_version: '7.0'

  within_files 'config/application.rb' do
    find_node '.send[receiver=.send[receiver=nil][message=config][arguments.size=0]][message=autoloader=][arguments.size=1]' do
      remove
    end
  end
end
