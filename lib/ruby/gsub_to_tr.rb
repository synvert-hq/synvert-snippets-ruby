# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'gsub_to_tr' do
  description <<~EOS
    It converts `String#gsub` to `String#tr`

    ```ruby
    'slug from title'.gsub(' ', '_')
    ```

    =>

    ```ruby
    'slug from title'.tr(' ', '_')
    ```
  EOS

  within_files Synvert::ALL_RUBY_FILES do
    # 'slug from title'.gsub(' ', '_')
    # =>
    # 'slug from title'.tr(' ', '_')
    find_node '.send[message=gsub][arguments=[size=2][first=.str][last=.str]]' do
      if node.arguments.first.to_value.length == 1 && node.arguments.last.to_value.length < 2
        replace :message, with: 'tr'
      end
    end
  end
end
