Synvert::Rewriter.new 'rails', 'convert_rails_logger' do
  description "It converts RAILS_DEFAULT_LOGGER to Rails.logger."

  if_gem 'rails', {gte: '2.3.0'}

  %w(**/*.rb **/*.rake).each do |file_pattern|
    within_files file_pattern do
      with_node type: 'const', to_source: 'RAILS_DEFAULT_LOGGER' do
        replace_with "Rails.logger"
      end
    end
  end
end
