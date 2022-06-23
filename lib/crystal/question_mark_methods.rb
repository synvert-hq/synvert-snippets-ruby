# .../lib/crystal/question_mark_methods.rb
# frozen_string_literal: true

Synvert::Rewriter.new("crystal", "#{File.basename(__FILE__).split('.')[0]}") do
  description <<~EOS
    It converts `object#ruby_method_name?` to `object.crystal_method_name?`

    ```ruby
    object.end_with?(param)
    object.start_with?(param)
    object.include?(param)
    object.exist?(param)
    object.respond_to?(param)
    a_hash.key?(param)
    ```

    =>

    ```ruby
    object.ends_with?(param)
    object.starts_with?(param)
    object.includes?(param)
    object.exists?(param)
    object.responds_to?(param)
    a_hash.has_key?(param)
    ```
  EOS


  method_names = {
    'end_with?'   => 'ends_with?',
    'start_with?' => 'starts_with?',
    'include?'    => 'includes?',
    'exist?'      => 'exists?',
    'respond_to?' => 'responds_to?',
    'key?'        => 'has_key?',

  }

  method_names.each_pair do |ruby_name, crystal_name|
    within_files "**/*.rb" do
      with_node(
          type:       "send",
          message:    ruby_name,
          arguments:  {
            size: 1
          }
        ) do
        replace :receiver, with: "{{receiver}}"
        replace :message, with: crystal_name
      end
    end
  end
end
