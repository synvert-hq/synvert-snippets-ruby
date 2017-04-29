# encoding: utf-8

require 'spec_helper'

RSpec.describe 'Upgrade rails from 5.0 to 5.1' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/upgrade_5_0_to_5_1.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:post_model_content) {'
class Post < ApplicationRecord
  def configs
    rgb = HashWithIndifferentAccess.new
    rgb[:black] = "#000000"
    rgb = ActiveSupport::HashWithIndifferentAccess.new
    rgb[:white] = "#FFFFFF"

    Rails.application.config.secrets[:smtp_settings]["address"]
  end
end
    '}
    let(:post_model_rewritten_content) {'
class Post < ApplicationRecord
  def configs
    rgb = ActiveSupport::HashWithIndifferentAccess.new
    rgb[:black] = "#000000"
    rgb = ActiveSupport::HashWithIndifferentAccess.new
    rgb[:white] = "#FFFFFF"

    Rails.application.config.secrets[:smtp_settings][:address]
  end
end
    '}

    it 'converts', aggregate_failures: true do
      FileUtils.mkdir_p 'app/models'
      File.write 'app/models/post.rb', post_model_content
      @rewriter.process
      expect(File.read 'app/models/post.rb').to eq post_model_rewritten_content
    end
  end
end
