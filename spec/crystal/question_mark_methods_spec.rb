# .../spec/crystal/_template.rb
# frozen_string_literal: true

# an example spec template ...

require 'spec_helper'

RSpec.describe 'Crystal pluralize question mark methods' do
  let(:rewriter_name) { 'crystal/question_mark_methods' }
  let(:test_content) { <<~EOS }
    def doit(a_string='hello world')
      if  a_string.end_with?('world') &&
          (a_string.start_with? 'hello')
        puts a_string
      elsif a_string.include? 'old'
        puts "who is old?"
      elsif File.exist?(__FILE__)
        puts "yes I exist."
      else
        puts a_string.upcase
      end
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    def doit(a_string='hello world')
      if  a_string.ends_with?('world') &&
          (a_string.starts_with? 'hello')
        puts a_string
      elsif a_string.includes? 'old'
        puts "who is old?"
      elsif File.exists?(__FILE__)
        puts "yes I exist."
      else
        puts a_string.upcase
      end
    end
  EOS

  include_examples 'convertable'
end
