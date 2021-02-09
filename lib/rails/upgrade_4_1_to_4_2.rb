Synvert::Rewriter.new 'rails', 'upgrade_4_1_to_4_2' do
  description <<-EOF
1. it replaces config.serve_static_assets = ... with config.serve_static_files = ... in config files.

2. it inserts config.active_record.raise_in_transactional_callbacks = true in config/application.rb
  EOF

  within_files 'config/environments/*.rb' do
    # config.serve_static_assets = false
    # =>
    # config.serve_static_files = false
    with_node type: 'send', message: 'serve_static_assets=' do
      replace_with '{{receiver}}.serve_static_files = {{arguments}}'
    end
  end

  within_file 'config/application.rb' do
    # insert config.active_record.raise_in_transactional_callbacks = true
    with_node type: 'class', parent_class: 'Rails::Application' do
      unless_exist_node type: 'send',
                        receiver: {
                          type: 'send',
                          receiver: {
                            type: 'send',
                            message: 'config'
                          },
                          message: 'active_record'
                        },
                        message: 'raise_in_transactional_callbacks=' do
        append 'config.active_record.raise_in_transactional_callbacks = true'
      end
    end
  end
end
