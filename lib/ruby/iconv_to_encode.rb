Synvert::Rewriter.new 'ruby', 'iconv_to_encode' do
  description <<-EOF
It convert Iconv#iconv to String#encode

    Iconv.new('cp1252', 'utf-8').iconv(string)
    =>
    string.force_encoding('cp1252').encode('utf-8')
  EOF

  within_files '**/*.rb' do
    #Iconv.new('cp1252', 'utf-8').iconv(string)
    #=>
    #string.force_encoding('cp1252').encode('utf-8')
    with_node type: 'send', message: 'iconv', arguments: {size: 1, first: {type: 'str'}} do
      replace_with "{{arguments}}.{{receiver}}"
    end
    with_node type: 'send', receiver: 'Iconv', message: 'new', arguments: {size: 2} do
      replace_with "force_encoding({{arguments[0]}}).encode({{arguments[1]}})"
    end
  end
end