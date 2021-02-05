Synvert::Rewriter.new 'rails', 'add_application_job' do
  description <<-EOF
It adds app/models/application_job.rb file and replaces ActiveJob::Base with ApplicationJob in model files.

    class PostJob < ActiveJob::Base
    end

    =>

    class PostJob < ApplicationJob
    end
  EOF

  # adds file app/models/application_job.rb
  add_file 'app/jobs/application_job.rb', <<~EOS
    class ApplicationJob < ActiveJob::Base
    end
  EOS

  within_files 'app/jobs/**/*.rb' do
    # class PostJob < ActiveJob::Base
    # end
    # =>
    # class PostJob < ApplicationJob
    # end
    with_node type: 'class', name: { not: 'ApplicationJob' }, parent_class: 'ActiveJob::Base' do
      goto_node :parent_class do
        replace_with 'ApplicationJob'
      end
    end
  end
end