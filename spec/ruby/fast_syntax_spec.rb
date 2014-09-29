require 'spec_helper'

describe 'Ruby writes fast ruby' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/ruby/fast_syntax.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:test_content) {"
def test(&block)
  block.call
end

def test(foo, bar, &block)
  block.call foo, bar
end

(1..100).map { |i| i.to_s }

enum.map do
  # do something
end.flatten(1)

enum.inject({}) do |h, e|
  h.merge(e => e)
end

enum.each_with_object({}) do |e, h|
  h.merge!(e => e)
end

{:rails => :club}.fetch(:rails, (0..9).to_a)

'slug from title'.gsub(' ', '_')

a, b = 1, 2

array.each_with_index do |number, index|
  test(number, index)
end
    "}
    let(:test_rewritten_content) {"
def test
  yield
end

def test(foo, bar)
  yield foo, bar
end

(1..100).map(&:to_s)

enum.flat_map do
  # do something
end

enum.inject({}) do |h, e|
  h.merge!(e => e)
end

enum.each_with_object({}) do |e, h|
  h[e] = e
end

{:rails => :club}.fetch(:rails) { (0..9).to_a }

'slug from title'.tr(' ', '_')

a = 1
b = 2

index = 0
while index < array.size
  number = array[index]
  test(number, index)
  index += 1
end
    "}

    it 'converts' do
      File.write 'test.rb', test_content
      @rewriter.process
      expect(File.read 'test.rb').to eq test_rewritten_content
    end
  end
end
