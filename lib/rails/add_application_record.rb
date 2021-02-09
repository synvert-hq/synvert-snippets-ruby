Synvert::Rewriter.new 'rails', 'add_application_record' do
  description <<~EOF
    It adds app/models/application_record.rb file and replaces ActiveRecord::Base with ApplicationRecord in model files.
    
        class Post < ActiveRecord::Base
        end
    
        =>
    
        class Post < ApplicationRecord
        end
  EOF

  # adds file app/models/application_record.rb
  add_file 'app/models/application_record.rb', <<~EOS
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  EOS

  within_files 'app/models/**/*.rb' do
    # class Post < ActiveRecord::Base
    # end
    # =>
    # class Post < ApplicationRecord
    # end
    with_node type: 'class', name: { not: 'ApplicationRecord' }, parent_class: 'ActiveRecord::Base' do
      goto_node :parent_class do
        replace_with 'ApplicationRecord'
      end
    end
  end
end