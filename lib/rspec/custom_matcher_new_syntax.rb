# frozen_string_literal: true

Synvert::Rewriter.new 'rspec', 'custom_matcher_new_syntax' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It uses RSpec::Matchers new syntax.

    ```ruby
    RSpec::Matchers.define :be_awesome do
      match_for_should { }
      match_for_should_not { }
      failure_message_for_should { }
      failure_message_for_should_not { }
    end
    ```

    =>

    ```ruby
    RSpec::Matchers.define :be_awesome do
      match { }
      match_when_negated { }
      failure_message { }
      failure_message_when_negated { }
    end
    ```
  EOS

  if_gem 'rspec-core', '>= 3.0'

  within_files Synvert::RAILS_RSPEC_FILES do
    within_node type: 'block', caller: { receiver: 'RSpec::Matchers', message: 'define' } do
      # RSpec::Matchers.define :be_awesome do
      #   match_for_should { }
      #   match_for_should_not { }
      #   failure_message_for_should { }
      #   failure_message_for_should_not { }
      # end
      # =>
      # RSpec::Matchers.define :be_awesome do
      #   match { }
      #   match_when_negated { }
      #   failure_message { }
      #   failure_message_when_negated { }
      # end
      {
        match_for_should: 'match',
        match_for_should_not: 'match_when_negated',
        failure_message_for_should: 'failure_message',
        failure_message_for_should_not: 'failure_message_when_negated'
      }.each do |old_message, new_message|
        with_node type: 'block', caller: { receiver: nil, message: old_message } do
          replace :caller, with: new_message
        end
      end
    end
  end
end
