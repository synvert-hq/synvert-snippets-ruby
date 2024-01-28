# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_models_3_2_to_4_0' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It converts rails models from 3.2 to 4.0.

    1. it replaces instance method serialized_attributes with class method.

    ```ruby
    self.serialized_attributes
    ```

    =>

    ```ruby
    self.class.serialized_attributes
    ```

    2. it replaces `dependent: :restrict` to `dependent: :restrict_with_exception`.
  EOS

  if_gem 'activerecord', '>= 4.0'

  within_files Synvert::RAILS_MODEL_FILES do
    # self.serialized_attributes => self.class.serialized_attributes
    with_node node_type: 'send', receiver: 'self', message: 'serialized_attributes' do
      replace_with 'self.class.serialized_attributes'
    end

    # has_many :comments, dependent: :restrict => has_many :comments, dependent: restrict_with_exception
    %w[has_one has_many].each do |message|
      within_node node_type: 'send', receiver: nil, message: message do
        with_node node_type: 'pair', key: 'dependent', value: :restrict do
          replace_with 'dependent: :restrict_with_exception'
        end
      end
    end
  end
end
