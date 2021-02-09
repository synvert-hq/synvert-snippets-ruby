# TODO: do more
Synvert::Rewriter.new 'rails', 'upgrade_5_2_to_6_0' do
  description <<-EOF
  EOF

  add_snippet 'rails', 'convert_update_attributes_to_update'
end
