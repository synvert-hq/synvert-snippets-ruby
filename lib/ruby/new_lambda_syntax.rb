Synvert::Rewriter.new 'ruby', 'new_lambda_syntax' do
  description <<-EOF
Use ruby new lambda syntax

    lambda { # do some thing } => -> { # do some thing }
  EOF

  # Gem::Version initialize will strip RUBY_VERSION directly in ruby 1.9,
  # which is solved from ruby 2.0.0, which calls dup internally.
  if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new("1.9.0")
    within_files '**/*.rb' do
      # lambda { |a, b, c| a + b + c } => ->(a, b, c) { a + b + c }
      within_node type: 'block', caller: {type: 'send', message: 'lambda'} do
        if node.arguments.empty?
          replace_with "-> { {{body}} }"
        else
          replace_with "->({{arguments}}) { {{body}} }"
        end
      end
    end
  end
end
