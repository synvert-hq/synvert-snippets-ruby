# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'add_application_record' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It adds ApplicationRecord

    1. it adds app/models/application_record.rb file.
    2. it replaces ActiveRecord::Base with ApplicationRecord in model files.

    ```ruby
    class Post < ActiveRecord::Base
    end
    ```

    =>

    ```ruby
    class Post < ApplicationRecord
    end
    ```
  EOS

  if_gem 'activerecord', '>= 5.0'

  # adds file app/models/application_record.rb
  add_file 'app/models/application_record.rb', <<~EOS
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  EOS

  within_files Synvert::RAILS_MODEL_FILES do
    # class Post < ActiveRecord::Base
    # end
    # =>
    # class Post < ApplicationRecord
    # end
    with_node node_type: 'class', name: { not: 'ApplicationRecord' }, parent_class: 'ActiveRecord::Base' do
      replace :parent_class, with: 'ApplicationRecord'
    end
  end
end
