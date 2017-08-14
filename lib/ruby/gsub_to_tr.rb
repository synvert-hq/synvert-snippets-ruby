Synvert::Rewriter.new 'ruby', 'gsub_to_tr' do
  description <<-EOF
It converts String#gsub to String#tr

    'slug from title'.gsub(' ', '_')
    =>
    'slug from title'.tr(' ', '_')
  EOF

  within_files '**/*.rb' do
    # 'slug from title'.gsub(' ', '_')
    # =>
    # 'slug from title'.tr(' ', '_')
    with_node type: 'send', message: 'gsub', arguments: { size: 2, first: { type: 'str' }, last: { type: 'str' } } do
      if node.arguments.first.to_value.length == 1 && node.arguments.last.to_value.length < 2
        replace_with '{{receiver}}.tr({{arguments}})'
      end
    end
  end
end
