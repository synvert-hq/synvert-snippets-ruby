# frozen_string_literal: true

Synvert::Rewriter.new 'rspec', 'pending_to_skip' do
  description <<-EOF
It converts rspec pending to skip.

    it 'is skipped', :pending => true do
      do_something_possibly_fail
    end
    =>
    it 'is skipped', :skip => true do
      do_something_possibly_fail
    end

    pending 'is skipped' do
      do_something_possibly_fail
    end
    =>
    skip 'is skipped' do
      do_something_possibly_fail
    end

    it 'is skipped' do
      pending
      do_something_possibly_fail
    end
    =>
    it 'is skipped' do
      skip
      do_something_possibly_fail
    end

    it 'is run and expected to fail' do
      pending do
        do_something_surely_fail
      end
    end
    =>
    it 'is run and expected to fail' do
      skip
      do_something_surely_fail
    end
  EOF

  if_gem 'rspec', { gte: '3.0.0' }

  within_files 'spec/**/*.rb', sort_by: 'end_pos' do
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
      replace_with 'skip {{arguments}}'
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
        goto_node 'arguments' do
          goto_node 'last' do
            replace_with node.to_source.sub('pending', 'skip')
          end
        end
      end
    end
  end
end
