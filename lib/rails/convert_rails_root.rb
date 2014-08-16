Synvert::Rewriter.new 'convert_rails_root' do
  description <<-EOF
It converts RAILS_ROOT to Rails.root.

  RAILS_ROOT
  => Rails.root

  File.join(RAILS_ROOT, 'config/database.yml')
  => Rails.root.join('config/database.yml')

  RAILS_ROOT + 'config/database.yml')
  => Rails.root.join('config/database.yml')

  "\#{RAILS_ROOT}/config/database.yml"
  => Rails.root.join('config/database.yml')
  EOF

  if_gem 'rails', {gte: '2.3.0'}

  %w(**/*.rb **/*.rake).each do |file_pattern|
    within_files file_pattern do
      # RAILS_ROOT => Rails.root
      with_node type: 'const', to_source: 'RAILS_ROOT' do
        replace_with "Rails.root"
      end
    end

    within_files file_pattern do
      # File.join(Rails.root, 'config/database.yml')
      # =>
      # Rails.root.join('config/database.yml')
      with_node type: 'send', receiver: 'File', message: 'join', arguments: {first: 'Rails.root'} do
        other_arguments = node.arguments[1..-1].map(&:to_source).join(", ")
        replace_with "Rails.root.join(#{other_arguments})"
      end

      # Rails.root + '/config/database.yml'
      # =>
      # Rails.root.join('config/database.yml')
      with_node type: 'send', receiver: 'Rails.root', message: '+' do
        other_argument_str = node.arguments.first.to_source
        other_argument_str[1] = '' if '/' == other_argument_str[1]
        replace_with "Rails.root.join(#{other_argument_str})"
      end

      # "#{Rails.root}/config/database.yml"
      # =>
      # Rails.root.join('config/database.yml')
      with_node type: 'dstr', children: {first: {type: 'begin', children: {first: 'Rails.root'}}} do
        source = node.to_source
        source[1..14] = ''
        replace_with "Rails.root.join(#{source})"
      end
    end
  end
end
