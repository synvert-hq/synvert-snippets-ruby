# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'better_syntax' do
  configure(parser: Synvert::PARSER_PARSER)

  description 'It converts rspec code to better syntax, it calls all minitest sub snippets.'

  add_snippet 'minitest', 'assert_empty'
  add_snippet 'minitest', 'assert_equal_arguments_order'
  add_snippet 'minitest', 'assert_includes'
  add_snippet 'minitest', 'assert_instance_of'
  add_snippet 'minitest', 'assert_kind_of'
  add_snippet 'minitest', 'assert_match'
  add_snippet 'minitest', 'assert_nil'
  add_snippet 'minitest', 'assert_operator'
  add_snippet 'minitest', 'assert_path_exists'
  add_snippet 'minitest', 'assert_predicate'
  add_snippet 'minitest', 'assert_respond_to'
  add_snippet 'minitest', 'assert_silent'
  add_snippet 'minitest', 'assert_truthy'
  add_snippet 'minitest', 'hooks_super'
  add_snippet 'minitest', 'refute_empty'
  add_snippet 'minitest', 'refute_equal'
  add_snippet 'minitest', 'refute_false'
  add_snippet 'minitest', 'refute_includes'
  add_snippet 'minitest', 'refute_instance_of'
  add_snippet 'minitest', 'refute_kind_of'
  add_snippet 'minitest', 'refute_match'
  add_snippet 'minitest', 'refute_nil'
  add_snippet 'minitest', 'refute_operator'
  add_snippet 'minitest', 'refute_path_exists'
  add_snippet 'minitest', 'refute_predicate'
  add_snippet 'minitest', 'refute_respond_to'
end
