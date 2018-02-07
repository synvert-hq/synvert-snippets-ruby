FORMAT_PATTERN = /format\:\s\W\w+\W/
Synvert::Rewriter.new 'rspec', 'controller_keyword_argument' do
  actions = %w(get post put delete)
  within_files 'spec/controllers/**/**.rb' do
    with_node type: :block do
      if node.caller.message == :it || node.caller.message == :expect
        node.body.each do |method|
          begin
            if method.message.to_s.in?(actions) && method.receiver == nil && method.arguments.size > 1
              request_params = method.arguments[1].to_source
              request_action = method.arguments[0].to_source
              # binding.pry
              process_with_other_node(method) do
                request_params.gsub!("params:", "")
                pairs = request_params.gsub(/{|}/, "").split(",")
                format = pairs.select {|p| p.include?("format:")}.first
                pairs = pairs.reject {|p| p.include?("format:")}

                # For example:
                # ```ruby
                # get :index, params: params
                # ```
                #
                if !pairs[0].include?(":")
                  params = "params: #{pairs.join(", ")}"
                else
                  params = "params: {#{pairs.join(", ")}}"
                end
                new_params = [request_action, params, format].compact.join(", ")
                replace_with "#{method.message} #{new_params}"
              end
            end
          rescue Synvert::Core::MethodNotSupported
          end
        end
      end
    end
  end
end
