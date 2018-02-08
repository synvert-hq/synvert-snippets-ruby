FORMAT_PATTERN = /format\:\s\W\w+\W/
Synvert::Rewriter.new 'rspec', 'controller_keyword_argument' do
  actions = %w(get post put delete)
  within_files 'spec/controllers/**/**.rb' do
    with_node type: :block do
      in_it_block =
        begin
          node.caller.message == :it || node.caller.message == :expect
        rescue Synvert::Core::MethodNotSupported
          false
        end

      if in_it_block
        node.body.each do |method_call|
          next if method_call.type != :send

          begin
            if method_call.message.to_s.in?(actions) && method_call.arguments.size > 1
              request_options = method_call.arguments[1]
              request_action = method_call.arguments[0].to_source
              pairs = {}
              param_string = ""
              session_string = ""

              case request_options.type
              when :send
                param_string = request_options.to_source
              when :lvar
                param_string = "params: #{request_options.to_source}"
              else
                request_options.keys.each_with_index do |key, index|
                  value = request_options.values[index].to_source
                  case key.to_source
                  when "format"
                    pairs["format"] = value
                  when "params"
                    param_string = "params: #{value}"
                  when "session"
                    session_string = "session: #{value}"
                  else
                    pairs["params"] ||= {}
                    pairs["params"][key.to_source] = value
                  end
                end

                if pairs["params"].present?
                  params = []
                  pairs["params"].each do |k, v|
                    params.push([k, v].join(": "))
                  end
                  param_string = "params: {#{params.join(", ")}}"
                end
              end


              param_string += ", format: #{pairs["format"]}" if pairs["format"].present?
              process_with_other_node(method_call) do
                replace_with "#{method_call.message} #{request_action}, #{param_string}"
              end
            end
          rescue Synvert::Core::MethodNotSupported => e
            require "pry"
            binding.pry
          end
        end
      end
    end
  end
end
