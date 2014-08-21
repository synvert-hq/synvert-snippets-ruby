Synvert::Rewriter.new 'rspec', 'new_syntax' do
  description <<-EOF
It converts rspec code to new syntax, it calls all convert_rspec_* snippets.

It also removes `config.treat_symbols_as_metadata_keys_with_true_values = true` from `spec/spec_helper.rb`
  EOF

  add_snippet 'rspec', 'should_to_expect'
  add_snippet 'rspec', 'block_to_expect'
  add_snippet 'rspec', 'one_liner_expectation'
  add_snippet 'rspec', 'boolean_matcher'
  add_snippet 'rspec', 'be_close_to_be_within'
  add_snippet 'rspec', 'collection_matcher'
  add_snippet 'rspec', 'negative_error_expectation'
  add_snippet 'rspec', 'its_to_it'

  add_snippet 'rspec', 'stub_and_mock_to_double'
  add_snippet 'rspec', 'message_expectation'
  add_snippet 'rspec', 'method_stub'


  if_gem 'rspec', {gte: '2.99.0'}

  within_file 'spec/spec_helper.rb' do
    # remove config.treat_symbols_as_metadata_keys_with_true_values = true
    with_node type: 'send', message: 'treat_symbols_as_metadata_keys_with_true_values=' do
      remove
    end
  end
end
