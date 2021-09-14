# frozen_string_literal: true

require 'spec_helper'

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.7')
  RSpec.describe 'Ruby numbered parameters' do
    let(:rewriter_name) { 'ruby/numbered_parameters' }
    let(:test_content) { <<~EOS }
      squared_numbers = (1...10).map { |num| num ** 2 }

      city_populations.each { |city, population| puts "Population of \#{city} is \#{population}" }
    EOS

    let(:test_rewritten_content) { <<~EOS }
      squared_numbers = (1...10).map { _1 ** 2 }

      city_populations.each { puts "Population of \#{_1} is \#{_2}" }
    EOS

    include_examples 'convertable'
  end
end
