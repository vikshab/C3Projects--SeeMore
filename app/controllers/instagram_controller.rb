class InstagramController < ApplicationController
  SEARCH_URI = "https://api.instagram.com/v1/users/search?client_id=#{ ENV["INSTAGRAM_CLIENT_ID"] }&count=10"
  FEED_URI_A = "https://api.instagram.com/v1/users/" # then user_id (for us: feed_id)
  FEED_URI_B = "/media/recent?client_id=#{ ENV["INSTAGRAM_CLIENT_ID"] }"

  def search
    # params: { instagram: { query: "vikshab" } }
    query = params.require(:instagram).require(:query)
    # => "vikshab"
    # query = params.require(:instagram).permit(:query)
    # => { query: "vikshab" }
    # query = "vikshab"

    redirect_to results_path(query)
  end

  def results
    @query = params[:query]
    search_url = SEARCH_URI + "&q=#{ @query }"
    results = HTTParty.get(search_url)
    @results = results["data"]
  end

  def individual_feed
    feed_url = FEED_URI_A + params[:feed_id] + FEED_URI_B
    results = HTTParty.get(feed_url)
    @posts = results["data"]
    flash.now[:error] = "This feed does not have any public posts." unless @posts
  end

  def subscribe
    # check whether this feed is already in the database
    # if not, add it to the database
    # if so, don't
    # then and only then add an entry in the join table to associate the user with the feed_url
  end
end
