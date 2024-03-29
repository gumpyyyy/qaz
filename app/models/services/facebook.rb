class Services::Facebook < Service
  include Rails.application.routes.url_helpers
  include MarkdownifyHelper

  OVERRIDE_FIELDS_ON_FB_UPDATE = [:follower_id, :person_id, :request_id, :invitation_id, :photo_url, :name, :username]
  MAX_CHARACTERS = 420

  def provider
    "facebook"
  end

  def post(post, url='')
    Rails.logger.debug("event=post_to_service type=facebook sender_id=#{self.user_id}")
    response = post_to_facebook("https://graph.facebook.com/me/feed", create_post_params(post).to_param)
    response = JSON.parse response.body
    post.facebook_id = response["id"]
    post.save
  end

  def post_to_facebook(url, body)
    Faraday.post(url, body)
  end

  def create_post_params(post)
    message = strip_markdown(post.text(:plain_text => true))
    if post.photos.any?
      message += " " + Rails.application.routes.url_helpers.short_post_url(post, :protocol => AppConfig.pod_uri.scheme, :host => AppConfig.pod_uri.authority)
    end
    {:message => message, :access_token => self.access_token, :link => URI.extract(message, ['https', 'http']).first}
  end

  def profile_photo_url
   "https://graph.facebook.com/#{self.uid}/picture?type=large&access_token=#{URI.escape(self.access_token)}"
  end

  def delete_post(post)
    if post.present? && post.facebbook_id.present?
      Rails.logger.debug("event=delete_from_service type=facebook sender_id=#{self.user_id}")
      delete_from_facebook("https://graph.facebook.com/#{post.facebook_id}/", {:access_token => self.access_token})
    end
  end

  def delete_from_facebook(url, body)
    Faraday.delete(url, body)
  end
end
