# frozen_string_literal: true

require 'spec_helper'

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.4')
  RSpec.describe 'Ruby uses it keyword' do
    let(:rewriter_name) { 'ruby/use_it_keyword' }
    let(:test_content) { <<~EOS }
      squared_numbers = (1...10).map { |num| num ** 2 }
      squared_numbers = (1...10).map { _1 ** 2 }

      city_populations.each { |city, population| puts "Population of \#{city} is \#{population}" }
      city_populations.each { puts "Population of \#{_1} is \#{_2}" }
    EOS

    let(:test_rewritten_content) { <<~EOS }
      squared_numbers = (1...10).map { it ** 2 }
      squared_numbers = (1...10).map { it ** 2 }

      city_populations.each { |city, population| puts "Population of \#{city} is \#{population}" }
      city_populations.each { puts "Population of \#{_1} is \#{_2}" }
    EOS

    include_examples 'convertable'
  end
end
