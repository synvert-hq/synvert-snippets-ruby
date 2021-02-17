# frozen_string_literal: true

Synvert::Rewriter.new 'rspec', 'boolean_matcher' do
  description <<~EOS
    It converts rspec boolean matcher.

    ```ruby
    be_true
    be_false
    ```

    =>

    ```ruby
    be_truthy
    be_falsey
    ```
  EOS

  if_gem 'rspec', { gte: '2.99.0' }

  within_files 'spec/**/*_spec.rb' do
    # be_true => be_truthy
    # be_false => be_falsey
    { be_true: 'be_truthy', be_false: 'be_falsey' }.each do |old_matcher, new_matcher|
      with_node type: 'send', receiver: nil, message: old_matcher do
        replace_with new_matcher
      end
    end
  end
end
