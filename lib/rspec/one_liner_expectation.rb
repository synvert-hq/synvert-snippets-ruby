# frozen_string_literal: true

Synvert::Rewriter.new 'rspec', 'one_liner_expectation' do
  description <<-EOF
It convers rspec one liner expectation.

    it { should matcher } => it { is_expected.to matcher }
    it { should_not matcher } => it { is_expected.not_to matcher }

    it { should have(3).items }
    =>
    it 'has 3 items' do
      expect(subject.size).to eq(3)
    end

    it { should have_at_least(3).players }
    =>
    it 'has at least 3 players' do
      expect(subject.players.size).to be >= 3
    end
  EOF

  if_gem 'rspec', { gte: '2.99.0' }

  matcher_converters = { have: 'eq', have_exactly: 'eq', have_at_least: 'be >=', have_at_most: 'be <=' }
  within_files 'spec/**/*.rb' do
    { should: 'to', should_not: 'not_to' }.each do |old_message, new_message|
      # it { should matcher } => it { is_expected.to matcher }
      # it { should_not matcher } => it { is_expected.not_to matcher }
      with_node type: 'block', caller: { message: 'it' } do
        if_only_exist_node type: 'send', receiver: nil, message: old_message do
          receiver = node.body.first.arguments.first.receiver
          unless receiver && matcher_converters.include?(receiver.message)
            matcher = node.body.first.arguments.first.to_source
            replace_with "it { is_expected.#{new_message} #{matcher} }"
          end
        end
      end

      # it { should have(3).items }
      # =>
      # it 'has 3 items' do
      #   expect(subject.size).to eq(3)
      # end
      #
      # it { should have_at_least(3).players }
      # =>
      # it 'has at least 3 players' do
      #   expect(subject.players.size).to be >= 3
      # end
      matcher_converters.each do |old_matcher, new_matcher|
        with_node type: 'block', caller: { message: 'it' } do
          if_only_exist_node type: 'send',
                             receiver: nil,
                             message: old_message,
                             arguments: {
                               first: {
                                 type: 'send',
                                 receiver: {
                                   type: 'send',
                                   message: old_matcher
                                 }
                               }
                             } do
            times = node.body.first.arguments.first.receiver.arguments.first.to_source
            items_name = node.body.first.arguments.first.message
            if :items == items_name
              replace_with <<~EOS
                it 'has #{times} items' do
                  expect(subject.size).#{new_message} #{new_matcher}(#{times})
                end
              EOS
            else
              replace_with <<~EOS
                it '#{old_matcher.to_s.sub('have', 'has').gsub('_', ' ')} #{times} #{items_name}' do
                  expect(subject.#{items_name}.size).#{new_message} #{new_matcher} #{times}
                end
              EOS
            end
          end
        end
      end
    end
  end
end
