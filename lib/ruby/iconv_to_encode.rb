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
      must_silently_ignore_bad_chars = node.arguments[0].to_value.split("//").include?("IGNORE")
      cleaned_arg0 = node.arguments[0].to_source.gsub(/\/{2}[^\/']+/,'')
      cleaned_arg1 = node.arguments[1].to_source.gsub(/\/{2}[^\/']+/,'')
      encode_options = ""
      if(must_silently_ignore_bad_chars)
        encode_options = ", invalid: :replace, undef: :replace"
      end
      replace_with "force_encoding(#{cleaned_arg0}).encode(#{cleaned_arg1}#{encode_options})"
    end
  end
end
