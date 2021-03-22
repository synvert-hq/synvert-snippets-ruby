# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_rails_test_xhr_4_2_to_5_0' do
  description "It's deprecated, please use `rails/convert_rails_test_request_methods_4_2_to_5_0` instead"
  warn "It's deprecated, please use `rails/convert_rails_test_request_methods_4_2_to_5_0` instead"
end
