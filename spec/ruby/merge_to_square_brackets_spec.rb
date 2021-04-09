# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Ruby converts merge or merge! to []' do
  let(:rewriter_name) { 'ruby/merge_to_square_brackets' }
  let(:test_content) { <<~EOS }
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
  EOS

  let(:test_rewritten_content) { <<~EOS }
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
  EOS

  include_examples 'convertable'
end
