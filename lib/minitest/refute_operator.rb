# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_operator' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    Use `refute_operator` if expecting expected object is not binary operator of the actual object. Assertion passes if the expected object is not binary operator(example: greater than) the actual object.

    ```ruby
    refute(expected > actual)
    assert(!(expected > actual))
    ```

    =>

    ```ruby
    refute_operator(expected, :>, actual)
    refute_operator(expected, :>, actual)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    %i[< > <= >=].each do |operator|
      # refute(expected > actual)
      # =>
      # refute_operator(expected, :>, actual)
      find_node ".send[receiver=nil][message=refute][arguments.size=1]
                      [arguments.first=.send[message=#{operator}][arguments.size=1]]" do
        replace :message, with: 'refute_operator'
        replace :arguments, with: "{{arguments.first.receiver}}, :#{operator}, {{arguments.first.arguments.first}}"
      end

      # assert(!(expected > actual))
      # =>
      # refute_operator(expected, :>, actual)
      find_node ".send[receiver=nil][message=assert][arguments.size=1]
                      [arguments.first=.send[message=!]
                        [receiver=.begin[body.size=1][body.first=.send[message=#{operator}][arguments.size=1]]]]" do
        replace :message, with: 'refute_operator'
        replace :arguments,
                with: "{{arguments.first.receiver.body.first.receiver}}, :#{operator}, {{arguments.first.receiver.body.first.arguments.first}}"
      end
    end
  end
end
