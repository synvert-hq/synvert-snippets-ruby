Synvert::Rewriter.new 'rspec', 'explicit_spec_type' do
  description <<~eos
    It explicits spec type.
    
        RSpec.configure do |rspec|
        end
        =>
        RSpec.configure do |rspec|
          rspec.infer_spec_type_from_file_location!
        end
    
        describe SomeModel do
        end
        =>
        describe SomeModel, :type => :model do
        end
  eos

  if_gem 'rspec-rails', { gte: '2.99.0' }

  within_file 'spec/rails_helper.rb' do
    # RSpec.configure do |rspec|
    # end
    # =>
    # RSpec.configure do |rspec|
    #   rspec.infer_spec_type_from_file_location!
    # end
    within_node type: 'block', caller: { type: 'send', receiver: 'RSpec', message: 'configure' } do
      unless_exist_node type: 'send', message: 'infer_spec_type_from_file_location!' do
        append '{{arguments}}.infer_spec_type_from_file_location!'
      end
    end
  end

  # describe SomeModel do
  # end
  # =>
  # describe SomeModel, :type => :model do
  # end
  { models: 'model',
   controllers: 'controller',
   helpers: 'helper',
   mailers: 'mailer',
   requests: 'request',
   integration: 'request',
   api: 'request',
   routing: 'routing',
   views: 'view',
   features: 'feature' }.each do |directory, type|
    within_files "spec/#{directory}/*.rb" do
      top_level = true
      with_node type: 'send', message: 'describe' do
        unless_exist_node type: 'pair', key: 'type' do
          replace_with add_receiver_if_necessary("describe {{arguments}}, type: :#{type}") if top_level
        end
        top_level = false
      end
    end
  end
end
