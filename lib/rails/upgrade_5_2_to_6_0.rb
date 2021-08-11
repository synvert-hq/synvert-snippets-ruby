# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_5_2_to_6_0' do
  description <<-EOS
    It upgrades rails 5.2 to 6.0
  EOS

  add_snippet 'rails', 'convert_update_attributes_to_update'
  add_snippet 'ruby', 'define_class_from_classic_mode_to_zeitwerk_mode'

  if_gem 'rails', '>= 6.0'
end
