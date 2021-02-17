# frozen_string_literal: true

# TODO: do more
Synvert::Rewriter.new 'rails', 'upgrade_5_2_to_6_0' do
  description <<-EOS
  EOS

  add_snippet 'rails', 'convert_update_attributes_to_update'

  if_gem 'rails', { gte: '6.0.0' }
end
