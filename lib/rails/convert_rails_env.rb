Synvert::Rewriter.new 'convert_rails_env' do
  description "It converts RAILS_ENV to Rails.env."

  if_gem 'rails', {gte: '2.3.0'}

  %w(**/*.rb **/*.rake).each do |file_pattern|
    within_files file_pattern do
      # RAILS_ENV == 'test'
      # =>
      # Rails.env == 'test'
      with_node type: 'const', to_source: 'RAILS_ENV' do
        replace_with "Rails.env"
      end
    end
  end

  %w(**/*.rb **/*.rake).each do |file_pattern|
    within_files file_pattern do
      # Rails.env == 'test'
      # =>
      # Rails.env.test?
      with_node type: 'send', receiver: 'Rails.env', message: '==' do
        if node.arguments.size == 1
          env = node.arguments.first.to_value
          replace_with "Rails.env.#{env}?"
        end
      end

      # 'development' == Rails.env
      # =>
      # Rails.env.development?
      with_node type: 'send', arguments: {first: 'Rails.env'}, message: '==' do
        env = node.receiver.to_value
        replace_with "Rails.env.#{env}?"
      end

      # Rails.env != 'test'
      # =>
      # !Rails.env.test?
      with_node type: 'send', receiver: 'Rails.env', message: '!=' do
        if node.arguments.size == 1
          env = node.arguments.first.to_value
          replace_with "!Rails.env.#{env}?"
        end
      end

      # 'development' != Rails.env
      # =>
      # !Rails.env.development?
      with_node type: 'send', arguments: {first: 'Rails.env'}, message: '!=' do
        env = node.receiver.to_value
        replace_with "!Rails.env.#{env}?"
      end
    end
  end
end
