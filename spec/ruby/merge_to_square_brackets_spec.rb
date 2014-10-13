require 'spec_helper'

describe 'Ruby converts merge or merge! to []' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/ruby/merge_to_square_brackets.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:test_content) {"
enum.inject({}) do |h, e|
  h.merge(e => e)
end

enum.inject({}) { |h, e| h.merge!(e => e) }

enum.each_with_object({}) do |e, h|
  h.merge(e => e)
end

enum.each_with_object({}) { |e, h| h.merge!(e => e) }

params.merge!(:a => 'b')
params.merge!(a: 'b')
    "}
    let(:test_rewritten_content) {"
enum.inject({}) do |h, e|
  h[e] = e
  h
end

enum.inject({}) { |h, e| h[e] = e; h }

enum.each_with_object({}) do |e, h|
  h[e] = e
end

enum.each_with_object({}) { |e, h| h[e] = e }

params[:a] = 'b'
params[:a] = 'b'
    "}

    it 'converts' do
      File.write 'test.rb', test_content
      @rewriter.process
      expect(File.read 'test.rb').to eq test_rewritten_content
    end
  end
end
