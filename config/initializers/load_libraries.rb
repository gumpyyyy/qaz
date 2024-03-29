# Stdlib
require 'cgi'
require 'uri'

# Not auto required gems
require 'active_support/base64'
require 'builder/xchar'
require 'carrierwave/orm/activerecord'
require 'erb'
require 'redcarpet/render_strip'
require 'typhoeus'

# Presenters
require 'post_presenter'

# Helpers
require 'markdownify_helper'

# Our libs
require 'collect_user_photos'
require 'lygneo'
require 'direction_detector'
require 'email_inviter'
require 'evil_query'
require 'federation_logger'
require 'h_card'
require 'hydra_wrapper'
require 'postzord'
require 'publisher'
require 'pubsubhubbub'
require 'salmon'
require 'statistics'
require 'stream'
require 'template_picker'
require 'webfinger'
require 'webfinger_profile'
