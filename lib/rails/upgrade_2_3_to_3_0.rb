Synvert::Rewriter.new 'upgrade_rails_2_3_to_3_0' do
  description <<-EOF
It converts rails from 2.3 to 3.0, it calls

  convert_rails_env
  convert_rails_root
  convert_rails_logger
  convert_routes_2_3_to_3_0
  convert_named_scope_to_scope

snippets.
  EOF

  add_snippet "convert_rails_env"
  add_snippet "convert_rails_root"
  add_snippet "convert_rails_logger"
  add_snippet "convert_routes_2_3_to_3_0"
  add_snippet "convert_named_scope_to_scope"

end
