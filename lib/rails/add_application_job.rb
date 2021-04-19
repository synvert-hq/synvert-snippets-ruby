# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'add_application_job' do
  description <<~EOS
    It adds ApplicationJob

    1. it adds app/models/application_job.rb file.

    2. it replaces ActiveJob::Base with ApplicationJob in job files.

    ```ruby
    class PostJob < ActiveJob::Base
    end
    ```

    =>

    ```ruby
    class PostJob < ApplicationJob
    end
    ```
  EOS

  if_gem 'activejob', '>= 5.0'

  # adds file app/jobs/application_job.rb
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
      replace :parent_class, with: 'ApplicationJob'
    end
  end
end
