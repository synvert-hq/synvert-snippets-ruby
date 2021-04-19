# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'add_application_mailer' do
  description <<~EOS
    It adds ApplicationMailer

    1. it adds app/mailers/application_mailer.rb file.

    2. it replaces ActionMailer::Base with ApplicationMailer in mailer files.

    ```ruby
    class UserMailer < ActionMailer::Base
    end
    ```

    =>

    ```ruby
    class UserMailer < ApplicationMailer
    end
    ```
  EOS

  if_gem 'actionmailer', '>= 5.0'

  # adds file app/mailers/application_mailer.rb
  add_file 'app/mailers/application_mailer.rb', <<~EOS
    class ApplicationMailer < ActionMailer::Base
    end
  EOS

  within_files 'app/mailers/**/*.rb' do
    # class UserMailer < ActionMailer::Base
    # end
    # =>
    # class UserMailer < ApplicationMailer
    # end
    with_node type: 'class', name: { not: 'ApplicationMailer' }, parent_class: 'ActionMailer::Base' do
      replace :parent_class, with: 'ApplicationMailer'
    end
  end
end
