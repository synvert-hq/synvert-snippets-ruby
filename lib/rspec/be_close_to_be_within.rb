# frozen_string_literal: true

Synvert::Rewriter.new 'rspec', 'be_close_to_be_within' do
  description <<~EOS
    It converts rspec be_close matcher to be_within matcher.

    ```ruby
    expect(1.0 / 3.0).to be_close(0.333, 0.001)
    ```

    =>

    ```ruby
    expect(1.0 / 3.0).to be_within(0.001).of(0.333)
    ```
  EOS

  if_gem 'rspec', '>= 2.1'

  within_files 'spec/**/*.rb' do
    # expect(1.0 / 3.0).to be_close(0.333, 0.001) => expect(1.0 / 3.0).to be_within(0.001).of(0.333)
    with_node type: 'send', message: 'to', arguments: { first: { type: 'send', message: 'be_close' } } do
      within_arg = node.arguments.first.arguments.last.to_source
      of_arg = node.arguments.first.arguments.first.to_source
      replace :arguments, with: "be_within(#{within_arg}).of(#{of_arg})"
    end
  end
end
