# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_render_nothing_true_to_head_ok' do
  description "It's deprecated, please use `rails/convert_head_response` instead"
  warn "It's deprecated, please use `rails/convert_head_response` instead"
end