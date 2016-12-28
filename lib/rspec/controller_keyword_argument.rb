Synvert::Rewriter.new 'rspec', 'controller_keyword_argument' do
  actions = %w(get post put delete)
  within_files 'spec/controllers/**/**.rb' do
    with_node type: :block do
      if node.caller.message == :it || node.caller.message == :expect
        node.body.each do |method|
          begin
            if method.message.to_s.in?(actions) && method.receiver == nil
              request_params = method.arguments.last.to_source
              request_action = method.arguments.first.to_source
              unless request_params.include?("params:")
                process_with_other_node(method) do
                  if request_params != request_action
                    if request_params.include?(":")
                      replace_with "#{method.message.to_s} #{request_action}, params: { #{request_params} }"
                    else
                      replace_with "#{method.message.to_s} #{request_action}, params: #{request_params}"
                    end
                  end
                end
              end
            end
          rescue Synvert::Core::MethodNotSupported
          end
        end
      end
    end
  end
end
