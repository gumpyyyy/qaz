require Rails.root.join('config', 'environment', 'development')

Lygneo::Application.configure do
  # Enable threaded mode
  config.threadsafe!
end
