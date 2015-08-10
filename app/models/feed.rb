class Feed < ActiveRecord::Base
  # Callbacks ------------------------------------------------------------------
  after_create :populate_posts

  # Associations ---------------------------------------------------------------
  has_and_belongs_to_many :au_users
  has_many :posts

  # Feed URI constants ---------------------------------------------------------
  # TODO: consider whether this should remain as media/recent. just realized there might be a longer feed available.
  INSTAGRAM_BASE_URI = "https://api.instagram.com/v1/users/" # ig's user_id == our feed_id
  INSTAGRAM_FEED_END_URI = "/media/recent?client_id=#{ ENV["INSTAGRAM_CLIENT_ID"] }"
  VIMEO_BASE_URI = "https://api.vimeo.com/users/" # vm's user_id == our feed_id
  VIMEO_FEED_END_URI = "/videos?page=1&per_page=30"
  VIMEO_TOKEN_HEADER = {
                   "Accept" => "application/vnd.vimeo.*+json;version=3.2",
                   "Authorization" => "bearer #{ ENV["VIMEO_ACCESS_TOKEN"] }"
                 }

  # Validations-----------------------------------------------------------------
  validates :name, :platform, :platform_feed_id, presence: true

  # Scopes ---------------------------------------------------------------------
  scope :developer, -> { where(platform: "developer") }
  scope :instagram, -> { where(platform: "instagram") }
  scope :vimeo, -> { where(platform: "vimeo") }

  # Instance Methods -----------------------------------------------------------

  # Creating feeds ------------

  def populate_posts
    if platform == "Instagram" || platform == "Developer"
      populate_instagram_feed
    elsif platform == "Vimeo"
      populate_vimeo_feed
    end
  end

  def populate_instagram_feed
    feed_url = INSTAGRAM_BASE_URI + platform_feed_id.to_s + INSTAGRAM_FEED_END_URI
    results = HTTParty.get(feed_url)
    posts = results["data"]
    posts.each do |post|
      maybe_valid_post = Post.create(create_instagram_post(post, self.id))
    end
  end

  def populate_vimeo_feed
    feed_url = VIMEO_BASE_URI + platform_feed_id.to_s + VIMEO_FEED_END_URI
    json_string_results = HTTParty.get(feed_url, :headers => VIMEO_TOKEN_HEADER )
    json_results = JSON.parse(json_string_results)
    posts = json_results["data"]
    posts.each do |post|
      maybe_valid_post = Post.create(create_vimeo_post(post, self.id))
    end
  end

  # Updating feeds -------------

  def check_for_updates
    if platform == "instagram" || platform == "developer"
      update_instagram_feed
    elsif platform == "vimeo"
      update_vimeo_feed
    else
      update_instagram_feed
    end
  end

  def update_instagram_feed
    # FIXME: this doesn't handle for posts that have been edited
    # FIXME continued: it only handles for posts that have been deleted
    feed_posts = self.posts
    feed_post_ids = feed_posts.map { |post| post.post_id }

    # query the API
    # OPTIMIZE: which of the following two lines is better?
    feed_url = INSTAGRAM_FEED_URI_A + platform_feed_id.to_s + INSTAGRAM_FEED_URI_B
    # feed_url = "#{ INSTAGRAM_FEED_URI_A }#{ platform_feed_id }#{ INSTAGRAM_FEED_URI_B }"
    results = HTTParty.get(feed_url)
    new_posts = results["data"]

    # create new posts from data
    updated_posts = []
    post_data.each do |post|
      post_id = post["id"]
      new_post = Post.create(create_instagram_post(post, self.id)) unless feed_post_ids.include? post_id
      updated_posts.push(new_post)
    end

    # delete any posts that are no longer present
    feed_posts.each do |post|
      unless updated_posts.include? post
        post.destroy
      end
    end
  end

  def update_vimeo_feed
    # query the API
    # save any new posts
    # update any posts that changed
      # maybe there was a typo, etc
    # delete any posts that stopped existing
      # privacy-- people might change the privacy stuff
      # deletion-- people might just delete something
  end

  # Private methods ------------------------------------------------------------
  private
    def create_instagram_post(post_data, feed_id)
      post_hash = {}
      post_hash[:post_id]     = post_data["id"] # post id from instagram
      post_hash[:description] = post_data["caption"]["text"] if post_data["caption"]
      post_hash[:content]     = post_data["images"]["low_resolution"]["url"]
      post_hash[:date_posted] = Time.at(post_data["created_time"].to_i)
      post_hash[:feed_id]     = feed_id # feed id from local feed object
      return post_hash
    end

    def create_vimeo_post(post_data, feed_id)
      post_hash = {}

      post_id_array = post_data["uri"].split("/") # "/videos/1234" => ["", "videos", "1234"]
      post_id = post_id_array.last # "1234"

      post_hash[:post_id]     = post_id # post id from vimeo
      post_hash[:name]        = post_data["name"] # FIXME: we need to add this column to the table
      post_hash[:description] = post_data["description"] # FIXME: in description, if description nil we can just put name
      post_hash[:content]     = post_data["embed"] # this is the HTML for embedding the video!
      post_hash[:date_posted] = post_data["created_time"]
      post_hash[:feed_id]     = feed_id # feed id from local feed object
      return post_hash
    end
end
