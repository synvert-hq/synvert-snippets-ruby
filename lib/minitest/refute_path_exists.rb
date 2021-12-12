# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_path_exists' do
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
    with_node type: 'send', receiver: nil, message: 'refute', arguments: { size: 1, first: { type: 'send', receiver: 'File', message: 'exist?', arguments: { size: 1 } } } do
      replace :message, with: 'refute_path_exists'
      replace :arguments, with: '{{arguments.first.arguments.first}}'
    end

    # assert(!File.exist?(path))
    # =>
    # refute_path_exists(path)
    with_node type: 'send', receiver: nil, message: 'assert', arguments: { size: 1, first: { type: 'send', receiver: { type: 'send', receiver: 'File', message: 'exist?', arguments: { size: 1 } }, message: '!' } } do
      replace :message, with: 'refute_path_exists'
      replace :arguments, with: '{{arguments.first.receiver.arguments.first}}'
    end
  end
end
