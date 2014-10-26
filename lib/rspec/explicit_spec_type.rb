Synvert::Rewriter.new 'rspec', 'explicit_spec_type' do
  description <<-eos
  eos

  if_gem 'rspec-rails', {gte: '2.99.0'}

  {models: 'model',
   controllers: 'controller',
   helpers: 'helper',
   mailers: 'mailer',
   requests: 'request',
   integration: 'request',
   api: 'request',
   routing: 'routing',
   views: 'view',
   features: 'feature'}.each do |directory,type|
    within_files "spec/#{directory}/*.rb" do
      top_level = true
      with_node type: 'send', message: 'describe' do
        replace_with add_receiver_if_necessary("describe {{arguments}}, type: :#{type}") if top_level
        top_level = false
      end
    end
  end
end
