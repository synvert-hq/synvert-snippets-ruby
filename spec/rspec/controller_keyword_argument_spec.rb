require 'spec_helper'

RSpec.describe 'Use keyword argument to pass request params in controller spec' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rspec/controller_keyword_argument.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:production_content) {'
RSpec.describe TestController, type: :controller do
  describe "#show" do
    let(:user) { create(:user, name: name) }
    it "returns status 200" do
      create(:post, user: user)
      get :show, id: 1
      expect(response).to be_ok
    end
    it "with multiple params" do
      get :show, id: 1, user_id: user.id
      expect(response).to be_ok
    end
    it "with keyword params already" do
      get :show, params: { id: 1, user_id: 1}
      expect(response).to be_ok
    end
  end
  describe "#create" do
    it "returns status 200" do
      post :create, title: "test"
      expect(response).to be_ok
    end
  end
  describe "#update" do
    it "changes post\'s title" do
      post = create(:post)
      expect {
        put :update, id: post.id, title: "test2"
      }.to change(post.title)
    end
    it "updates post" do
      post = create(:post)
      params = { id: post.id, title: "test2", content: "123" }

      put :update, params
    end
  end
end
    '}
    let(:production_rewritten_content) {'
RSpec.describe TestController, type: :controller do
  describe "#show" do
    let(:user) { create(:user, name: name) }
    it "returns status 200" do
      create(:post, user: user)
      get :show, params: { id: 1 }
      expect(response).to be_ok
    end
    it "with multiple params" do
      get :show, params: { id: 1, user_id: user.id }
      expect(response).to be_ok
    end
    it "with keyword params already" do
      get :show, params: { id: 1, user_id: 1}
      expect(response).to be_ok
    end
  end
  describe "#create" do
    it "returns status 200" do
      post :create, params: { title: "test" }
      expect(response).to be_ok
    end
  end
  describe "#update" do
    it "changes post\'s title" do
      post = create(:post)
      expect {
        put :update, params: { id: post.id, title: "test2" }
      }.to change(post.title)
    end
    it "updates post" do
      post = create(:post)
      params = { id: post.id, title: "test2", content: "123" }

      put :update, params: params
    end
  end
end
    '}

    it 'converts' do
      FileUtils.mkdir_p 'spec/controllers'
      File.write 'spec/controllers/test_controller_spec.rb', production_content
      @rewriter.process
      expect(File.read('spec/controllers/test_controller_spec.rb')).to eq(production_rewritten_content)
    end
  end
end
