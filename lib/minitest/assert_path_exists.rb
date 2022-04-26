# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_path_exists' do
  description <<~EOS
    Use `assert_path_exists` if expecting path to exist.

    ```ruby
    assert(File.exist?(path))
    ```

    =>

    ```ruby
    assert_path_exists(path)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    find_node '.send[receiver=nil][message=assert][arguments.size=1]
                    [arguments.first=.send[receiver=File][message=exist?][arguments.size=1]]' do
      replace :message, with: 'assert_path_exists'
      replace :arguments, with: '{{arguments.first.arguments.first}}'
    end
  end
end
