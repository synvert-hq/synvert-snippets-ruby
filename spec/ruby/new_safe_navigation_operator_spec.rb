# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Ruby uses new safe navigation operator',
               skip: Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.3.0') do
  let(:rewriter_name) { 'ruby/new_safe_navigation_operator' }

  context 'with arguments' do
    let(:test_content) {
      "
u = User.find(id)
u.try!(:profile).try!(:thumbnails).try!(:large, 100, format: 'jpg')
u.try!('profile').try!('thumbnails').try!('large', 100, format: 'jpg')
u.try(:profile).try(:thumbnails).try(:large, 100, format: 'jpg')
u.try('profile').try('thumbnails').try('large', 100, format: 'jpg')
    "
    }
    let(:test_rewritten_content) {
      "
u = User.find(id)
u&.profile&.thumbnails&.large(100, format: 'jpg')
u&.profile&.thumbnails&.large(100, format: 'jpg')
u&.profile&.thumbnails&.large(100, format: 'jpg')
u&.profile&.thumbnails&.large(100, format: 'jpg')
    "
    }

    include_examples 'convertable'
  end

  context 'without arguments' do
    let(:test_content) { 'u.try! {|u| do_something(u.profile) }' }
    let(:test_rewritten_content) { 'u.try! {|u| do_something(u.profile) }' }

    include_examples 'convertable'
  end
end
