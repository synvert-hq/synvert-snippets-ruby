# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_path_exists' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    Use `refute_path_exists` if expecting path to not exist.

    ```ruby
    assert(!File.exist?(path))
    refute(File.exist?(path))
    ```

    =>

    ```ruby
    refute_path_exists(path)
    refute_path_exists(path)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    # refute(File.exist?(path))
    # =>
    # refute_path_exists(path)
    find_node '.send[receiver=nil][message=refute][arguments.size=1]
                    [arguments.first=.send[receiver=File][message=exist?][arguments.size=1]]' do
      replace :message, with: 'refute_path_exists'
      replace :arguments, with: '{{arguments.first.arguments.first}}'
    end

    # assert(!File.exist?(path))
    # =>
    # refute_path_exists(path)
    find_node '.send[receiver=nil][message=assert][arguments.size=1]
                    [arguments.first=.send[message=!][receiver=.send[receiver=File][message=exist?][arguments.size=1]]]' do
      replace :message, with: 'refute_path_exists'
      replace :arguments, with: '{{arguments.first.receiver.arguments.first}}'
    end
  end
end
