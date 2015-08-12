require "#{ Rails.root }/lib/instagram_api"
include FriendFaceAPIs

require 'webmock/rspec'

describe "FriendFaceAPIs::InstagramAPI wrapper" do
  context "self.instagram_feed" do
    it "gets a response from an api"
      # VCR.use_cassette "/instagram_feed" do
      #   session[:user_id] = user.id
      #   get :results, query: query
      #   expect(assigns(:results).first["name"]).to eq "Cupcake"
      # end
    end
  end

  context "self.instagram_feed_info" do
    it "gets a response from an api"
      # VCR.use_cassette "/instagram_feed" do
      #   session[:user_id] = user.id
      #   get :results, query: query
      #   expect(assigns(:results).first["name"]).to eq "Cupcake"
      # end
    # end
  end

  context "self.instagram_search" do
    it "gets a response from an api"
      # VCR.use_cassette "/instagram_feed" do
      #   session[:user_id] = user.id
      #   get :results, query: query
      #   expect(assigns(:results).first["name"]).to eq "Cupcake"
      # end
    end
  end
end
