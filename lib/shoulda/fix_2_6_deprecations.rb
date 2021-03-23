# frozen_string_literal: true

Synvert::Rewriter.new 'shoulda', 'fix_2_6_deprecations' do
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

  %w[test/unit/**/*_test.rb spec/models/**/*_spec.rb].each do |file_pattern|
    within_files file_pattern do
      # should ensure_inclusion_of(:age).in_range(0..100)
      # =>
      # should validate_inclusion_of(:age).in_range(0..100)
      with_node type: 'send', message: 'ensure_inclusion_of' do
        replace_with 'validate_inclusion_of({{arguments}})'
      end

      # should ensure_exclusion_of(:age).in_range(0..100)
      # =>
      # should validate_exclusion_of(:age).in_range(0..100)
      with_node type: 'send', message: 'ensure_exclusion_of' do
        replace_with 'validate_exclusion_of({{arguments}})'
      end
    end
  end
end
