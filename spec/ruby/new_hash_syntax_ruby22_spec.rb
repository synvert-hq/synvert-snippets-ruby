require 'spec_helper'

RSpec.describe 'Ruby uses new hash synax in ruby 2.2' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/ruby/new_hash_syntax_ruby22.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.2.0')
    describe 'with fakefs', fakefs: true do
      let(:test_content) {
        <<'EOF'
{:foo => 'bar', 'foo' => 'bar'}
{:key1 => 'value1', :key2 => 'value2'}
{foo_key: 'foo_value', bar_key: 42, "baz-key" => true}
{:"foo-#{key}" => 'foo_value', :"bar-key" => 42, :"a\tb" => false, :"c'd" => nil}
{"foo-#{key}": 'foo_value', 'bar-key': 42, "a\tb": false, "c'd": nil}
EOF
      }

      let(:test_rewritten_content) {
        <<'EOF'
{foo: 'bar', 'foo' => 'bar'}
{key1: 'value1', key2: 'value2'}
{foo_key: 'foo_value', bar_key: 42, "baz-key" => true}
{"foo-#{key}": 'foo_value', 'bar-key': 42, "a\tb": false, "c'd": nil}
{"foo-#{key}": 'foo_value', 'bar-key': 42, "a\tb": false, "c'd": nil}
EOF
      }

      it 'converts' do
        File.write 'test.rb', test_content
        @rewriter.process
        expect(File.read 'test.rb').to eq test_rewritten_content
      end
    end
  end
end
