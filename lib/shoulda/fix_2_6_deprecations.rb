# frozen_string_literal: true

Synvert::Rewriter.new 'shoulda', 'fix_2_6_deprecations' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It fixes shoulda 2.6 deprecations.

    ```ruby
    should ensure_inclusion_of(:age).in_range(0..100)
    should ensure_exclusion_of(:age).in_range(0..100)
    ```

    =>

    ```ruby
    should validate_inclusion_of(:age).in_range(0..100)
    should validate_exclusion_of(:age).in_range(0..100)
    ```
  EOS

  if_gem 'shoulda-matchers', '> 2.6.2'

  within_files Synvert::RAILS_MODEL_TEST_FILES do
    # should ensure_inclusion_of(:age).in_range(0..100)
    # =>
    # should validate_inclusion_of(:age).in_range(0..100)
    find_node '.send[message=ensure_inclusion_of][arguments.size=1]' do
      replace :message, with: 'validate_inclusion_of'
    end

    # should ensure_exclusion_of(:age).in_range(0..100)
    # =>
    # should validate_exclusion_of(:age).in_range(0..100)
    find_node '.send[message=ensure_exclusion_of][arguments.size=1]' do
      replace :message, with: 'validate_exclusion_of'
    end
  end
end
