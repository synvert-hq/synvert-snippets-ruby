Synvert::Rewriter.new 'rspec', 'use_new_syntax' do
  description <<-EOF
It converts rspec code to new syntax, it calls all convert_rspec_* snippets.
  EOF

  add_snippet 'rspec', 'be_close_to_be_within'
  add_snippet 'rspec', 'block_to_expect'
  add_snippet 'rspec', 'boolean_matcher'
  add_snippet 'rspec', 'collection_matcher'
  add_snippet 'rspec', 'custom_matcher_new_syntax'
  add_snippet 'rspec', 'explicit_spec_type'
  add_snippet 'rspec', 'its_to_it'
  add_snippet 'rspec', 'message_expectation'
  add_snippet 'rspec', 'method_stub'
  add_snippet 'rspec', 'negative_error_expectation'
  add_snippet 'rspec', 'new_config_options'
  add_snippet 'rspec', 'new_hook_scope'
  add_snippet 'rspec', 'one_liner_expectation'
  add_snippet 'rspec', 'pending_to_skip'
  add_snippet 'rspec', 'remove_monkey_patches'
  add_snippet 'rspec', 'should_to_expect'
  add_snippet 'rspec', 'stub_and_mock_to_double'
end
