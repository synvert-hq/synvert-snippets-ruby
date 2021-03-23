# frozen_string_literal: true

Synvert::Rewriter.new 'rspec', 'collection_matcher' do
  description <<~EOS
    It converts rspec collection matcher.

    ```ruby
    expect(collection).to have(3).items
    expect(collection).to have_exactly(3).items
    expect(collection).to have_at_least(3).items
    expect(collection).to have_at_most(3).items

    expect(team).to have(3).players
    ```

    =>

    ```ruby
    expect(collection.size).to eq(3)
    expect(collection.size).to eq(3)
    expect(collection.size).to be >= 3
    expect(collection.size).to be <= 3

    expect(team.players.size).to eq 3
    ```
  EOS

  if_gem 'rspec', '>= 2.11'

  within_files 'spec/**/*_spec.rb' do
    # expect(collection).to have(3).items => expect(collection.size).to eq(3)
    # expect(collection).to have_exactly(3).items => expect(collection.size).to eq(3)
    # expect(collection).to have_at_least(3).items => expect(collection.size).to be >= 3
    # expect(collection).to have_at_most(3).items => expect(collection.size).to be <= 3
    #
    # expect(team).to have(3).players => expect(team.players.size).to eq 3
    {
      have: 'eq',
      have_exactly: 'eq',
      have_at_least: 'be >=',
      have_at_most: 'be <='
    }.each do |old_matcher, new_matcher|
      with_node type: 'send',
                message: 'to',
                arguments: {
                  first: {
                    type: 'send',
                    receiver: {
                      type: 'send',
                      message: old_matcher
                    }
                  }
                } do
        times = node.arguments.first.receiver.arguments.first.to_source
        items_name = node.arguments.first.message
        if :items == items_name
          replace_with "expect({{receiver.arguments}}.size).to #{new_matcher} #{times}"
        else
          replace_with "expect({{receiver.arguments}}.#{items_name}.size).to #{new_matcher} #{times}"
        end
      end
    end
  end
end
