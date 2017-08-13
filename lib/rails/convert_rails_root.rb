Synvert::Rewriter.new 'rails', 'convert_rails_root' do
  description <<-EOF
It converts RAILS_ROOT to Rails.root.

  RAILS_ROOT
  =>
  Rails.root

  File.join(RAILS_ROOT, 'config/database.yml')
  =>
  Rails.root.join('config/database.yml')

  RAILS_ROOT + 'config/database.yml')
  =>
  Rails.root.join('config/database.yml')

  "\#{RAILS_ROOT}/config/database.yml"
  =>
  Rails.root.join('config/database.yml')

  File.exists?(Rails.root.join('config/database.yml'))
  =>
  Rails.root.join('config/database.yml').exist?
  EOF

  if_gem 'rails', {gte: '2.3.0'}

  within_files '**/*.{rb,rake}' do
    # RAILS_ROOT => Rails.root
    with_node type: 'const', to_source: 'RAILS_ROOT' do
      replace_with 'Rails.root'
    end
    with_node type: 'const', to_source: '::RAILS_ROOT' do
      replace_with 'Rails.root'
    end
  end

  within_files '**/*.{rb,rake}' do
    # File.join(Rails.root, 'config/database.yml')
    # =>
    # Rails.root.join('config/database.yml')
    with_node type: 'send', receiver: 'File', message: 'join', arguments: {first: 'Rails.root'} do
      other_arguments = node.arguments[1..-1].map(&:to_source).join(', ')
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

  within_files '**/*.{rb,rake}' do
    # File.exists?(Rails.root.join('config/database.yml'))
    # =>
    # Rails.root.join('config/database.yml').exist?
    with_node type:'send', receiver: 'File', message: 'exists?', arguments: {size: 1, first: {type: 'send', receiver: 'Rails.root', message: 'join'}} do
      replace_with '{{arguments.first}}.exist?'
    end
  end
end
