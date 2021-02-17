# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_to_redirect_back' do
  description 'It converts `redirect_to :back` to `redirect_back`'

  within_file 'app/controllers/**/*.rb' do
    # redirect_to :back
    # =>
    # redirect_back
    with_node type: 'send', receiver: nil, message: 'redirect_to', arguments: [:back] do
      replace_with 'redirect_back'
    end
  end
end
