Synvert::Rewriter.new 'ruby', 'new_safe_navigation_operator' do
  description <<-EOF
Use ruby new safe navigation operator.

    u.try!(:profile).try!(:thumbnails).try!(:large)
    =>
    u&.profile&.thumbnails&.large
  EOF

  # Gem::Version initialize will strip RUBY_VERSION directly in ruby 1.9,
  # which is solved from ruby 2.0.0, which calls dup internally.
  if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new("2.3.0")
    within_files '**/*.rb' do
      # u.try!(:profile).try!(:thumbnails).try!(:large)
      # u.try(:profile).try(:thumbnails).try(:large)
      # =>
      # u&.profile&.thumbnails&.large
      # u&.profile&.thumbnails&.large
      %w(try! try).each do |message|
        within_node type: 'send', message: message do
          replace_with "{{receiver}}&.{{arguments.first.to_value}}"
        end
      end
    end
  end
end
