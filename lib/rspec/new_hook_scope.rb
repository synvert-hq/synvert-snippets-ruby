Synvert::Rewriter.new 'rspec', 'new_hook_scope' do
  description <<-EOF
It converts new hook scope.

    before(:each) { do_something }
    =>
    before(:example) { do_something }

    before(:all) { do_something }
    =>
    before(:context) { do_something }
  EOF

  if_gem 'rspec', { gte: '3.0.0' }

  within_files 'spec/**/*.rb' do
    # before(:each) { do_something }
    # =>
    # before(:example) { do_something }
    #
    # before(:all) { do_something }
    # =>
    # before(:context) { do_something }
    %w[before after around].each do |scope|
      with_node type: 'send', message: scope, arguments: [:all] do
        replace_with add_receiver_if_necessary("#{scope}(:context)")
      end

      with_node type: 'send', message: scope, arguments: [:each] do
        replace_with add_receiver_if_necessary("#{scope}(:example)")
      end
    end
  end
end
