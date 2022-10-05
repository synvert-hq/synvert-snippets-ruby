# frozen_string_literal: true

Synvert::Rewriter.new 'rspec', 'pending_to_skip' do
  description <<~EOS
    It converts rspec pending to skip.

    ```ruby
    it 'is skipped', :pending => true do
      do_something_possibly_fail
    end

    pending 'is skipped' do
      do_something_possibly_fail
    end

    it 'is skipped' do
      pending
      do_something_possibly_fail
    end

    it 'is run and expected to fail' do
      pending do
        do_something_surely_fail
      end
    end
    ```

    =>

    ```ruby
    it 'is skipped', :skip => true do
      do_something_possibly_fail
    end

    skip 'is skipped' do
      do_something_possibly_fail
    end

    it 'is skipped' do
      skip
      do_something_possibly_fail
    end

    it 'is run and expected to fail' do
      skip
      do_something_surely_fail
    end
    ```
  EOS

  if_gem 'rspec-core', '>= 3.0'

  within_files Synvert::RAILS_RSPEC_FILES do
    # it 'is run and expected to fail' do
    #   pending do
    #     do_something_surely_fail
    #   end
    # end
    # =>
    # it 'is run and expected to fail' do
    #   skip
    #   do_something_surely_fail
    # end
    with_node type: 'block', caller: { type: 'send', receiver: nil, message: 'pending', arguments: { size: 0 } } do
      replace_with "skip\n{{body}}"
    end

    # it 'is skipped' do
    #   pending
    #   do_something_possibly_fail
    # end
    # =>
    # it 'is skipped' do
    #   skip
    #   do_something_possibly_fail
    # end
    with_node type: 'send', receiver: nil, message: 'pending', arguments: { size: 0 } do
      replace_with 'skip'
    end

    # pending 'is skipped' do
    #   do_something_possibly_fail
    # end
    # =>
    # skip 'is skipped' do
    #   do_something_possibly_fail
    # end
    with_node type: 'send', receiver: nil, message: 'pending', arguments: { size: 1, first: { type: 'str' } } do
      replace :message, with: 'skip'
    end

    %w[it describe context].each do |message|
      # it 'is skipped', :pending => true do
      #   do_something_possibly_fail
      # end
      # =>
      # it 'is skipped', :skip => true do
      #   do_something_possibly_fail
      # end
      with_node type: 'send', message: message, arguments: { size: 2, last: { type: 'hash' } } do
        goto_node 'arguments.last' do
          with_node type: 'pair', key: :pending do
            replace 'key', with: node.key.to_source.sub('pending', 'skip')
          end
        end
      end
    end
  end
end
