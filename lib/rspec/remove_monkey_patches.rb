Synvert::Rewriter.new 'rspec', 'remove_monkey_patches' do
  description <<-EOF
It removes monkey patching of the top level methods like describe

    RSpec.configure do |rspec|
    end
    =>
    RSpec.configure do |rspec|
      rspec.expose_dsl_globally = false
    end

    describe 'top-level example group' do
      describe 'nested example group' do
      end
    end
    =>
    RSpec.describe 'top-level example group' do
      describe 'nested example group' do
      end
    end
  EOF

  if_gem 'rspec', { gte: '3.0.0' }

  monkey_patches_methods = %w[describe shared_examples shared_examples_for shared_context]

  within_files 'spec/**/*.rb' do
    top_level = true

    # describe 'top-level example group' do
    #   describe 'nested example group' do
    #   end
    # end
    # =>
    # RSpec.describe 'top-level example group' do
    #   describe 'nested example group' do
    #   end
    # end
    monkey_patches_methods.each do |message|
      with_node type: 'send', message: message do
        if !node.receiver && top_level
          replace_with 'RSpec.{{message}} {{arguments}}'
        end
        top_level = false
      end
    end
  end

  within_file 'spec/spec_helper.rb' do
    # RSpec.configure do |rspec|
    # end
    # =>
    # RSpec.configure do |rspec|
    #   rspec.expose_dsl_globally = false
    # end
    within_node type: 'block', caller: { type: 'send', receiver: 'RSpec', message: 'configure' } do
      unless_exist_node type: 'send', message: 'expose_dsl_globally=' do
        append '{{arguments}}.expose_dsl_globally = false'
      end
    end
  end
end
