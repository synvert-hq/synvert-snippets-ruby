
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rename bullet whitelist to safelist' do
  let(:rewriter_name) { 'bullet/rename_whitelist_to_safelist' }

  let(:test_content) { <<-EOS }
    Bullet.add_whitelist(type: :n_plus_one_query, class_name: 'Klass', association: :department)
    Bullet.delete_whitelist(type: :n_plus_one_query, class_name: 'Klass', association: :team)
    Bullet.get_whitelist_associations(:n_plus_one_query, 'Klass')
    Bullet.reset_whitelist
    Bullet.clear_whitelist
  EOS

  let(:test_rewritten_content) { <<-EOS }
    Bullet.add_safelist(type: :n_plus_one_query, class_name: 'Klass', association: :department)
    Bullet.delete_safelist(type: :n_plus_one_query, class_name: 'Klass', association: :team)
    Bullet.get_safelist_associations(:n_plus_one_query, 'Klass')
    Bullet.reset_safelist
    Bullet.clear_safelist
  EOS

  include_examples 'convertable'
end