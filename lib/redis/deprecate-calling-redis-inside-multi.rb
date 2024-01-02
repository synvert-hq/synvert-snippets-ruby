# frozen_string_literal: true

Synvert::Rewriter.new 'redis', 'deprecate-calling-redis-inside-multi' do
  configure(parser: Synvert::SYNTAX_TREE_PARSER)

  description <<~EOS
    Deprecate calling commands on `Redis` insdie `Redis#multi`.

    ```ruby
    redis.multi do
      redis.get("key")
    end
    ```

    =>

    ```ruby
    redis.multi do |transaction|
      transaction.get("key")
    end
    ```
  EOS

  if_gem 'redis', '>= 4.6.0'

  within_files Synvert::ALL_RUBY_FILES do
    find_node '.MethodAddBlock[call=.CallNode[message=multi]][block=.BlockNode[block_var=nil]]' do
      redis_name = node.call.receiver.to_source
      group do
        insert ' |transaction|', to: 'block.opening', at: 'end'
        goto_node 'block.bodystmt' do
          find_node ".CallNode[receiver=#{redis_name}]" do
            replace :receiver, with: 'transaction'
          end
        end
      end
    end
  end
end
