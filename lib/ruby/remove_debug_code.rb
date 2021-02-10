# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'remove_debug_code' do
  description <<~EOF
    It removes puts and p methods
  EOF

  within_files '**/*.rb' do
    # removes puts and p methods
    %w(puts p).each do |message|
      with_node type: 'send', message: message do
        remove
      end
    end
  end
end
