FORMAT_PATTERN = /format\:\s\W\w+\W/
Synvert::Rewriter.new 'rspec', 'controller_keyword_argument' do
  actions = %w(get post put delete)
  within_files 'spec/controllers/**/**.rb' do
    with_node type: :block do
      if node.caller.message == :it || node.caller.message == :expect
        node.body.each do |method_call|
          begin
            if method_call.message.to_s.in?(actions) && method_call.arguments.size > 1
              request_options = method_call.arguments[1]
              request_action = method_call.arguments[0].to_source
              pairs = {}
              param_string = ""

              request_options.keys.each_with_index do |key, index|

                case key.to_source
                when "format"
                  value = request_options.values[index].to_source
                  pairs["format"] = value
                when "params"
                  param_value_keys = request_options.values[index].keys
                  param_value_values = request_options.values[index].values
                  param_value_keys.each_with_index do |key, i|
                    if key.to_source == "format"
                      pairs["format"] = param_value_values[i].to_source
                    end
                  end
                  param_string = "params: #{request_options.values[index].to_source}"
                when "session"
                  break
                else
                  pairs["params"] ||= {}
                  value = request_options.values[index].to_source
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
