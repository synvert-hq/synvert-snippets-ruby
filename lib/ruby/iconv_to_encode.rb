Synvert::Rewriter.new 'ruby', 'iconv_to_encode' do
  description <<-EOF
It convert Iconv#iconv to String#encode

    Iconv.new('cp1252', 'utf-8').iconv(string)
    =>
    string.force_encoding('utf-8').encode('cp1252')
  EOF

  within_files '**/*.rb' do
    #Iconv.new('cp1252', 'utf-8').iconv(string)
    #=>
    #string.force_encoding('cp1252').encode('utf-8')
    #
    #require 'iconv'
    #=>
    #
    with_node type: 'send', message: 'require', arguments:['iconv'] do
      remove
    end

    with_node type: 'send', message: 'iconv', arguments: {size: 1} do
      replace_with "{{arguments}}.{{receiver}}"
    end
    with_node type: 'send', receiver: 'Iconv', message: 'new', arguments: {size: 2} do
      to_charset = node.arguments[0]
      from_charset = node.arguments[1]
      must_silently_ignore_bad_chars = from_charset.type == :str &&
        from_charset.to_value.split("//").include?("IGNORE")
      encode_options = ""
      if(must_silently_ignore_bad_chars)
        encode_options = ", invalid: :replace, undef: :replace"
      end
      cleaned_from_charset = from_charset.to_source.gsub(/\/{2}[^\/']+/,'')
      cleaned_to_charset = to_charset.to_source.gsub(/\/{2}[^\/']+/,'')
      replace_with(
        "force_encoding(#{cleaned_from_charset}).encode(#{cleaned_to_charset}#{encode_options})"
      )
    end
  end
end
