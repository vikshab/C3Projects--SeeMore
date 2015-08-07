class AuUser < ActiveRecord::Base
  has_and_belongs_to_many :feeds
  has_many :posts, through: :feeds

  validates :uid, :provider, :name, :presence => true

  def self.create_with_omniauth(auth)
    create! do |au_user|
      au_user.provider = auth["provider"]
      au_user.uid = auth["uid"]
      au_user.name = auth["info"]["name"]
      au_user.email = auth["info"]["email"]
      if au_user.avatar
        au_user.avatar = auth["info"]["pictures"][0]["link"]
      end
    end
  end
end
