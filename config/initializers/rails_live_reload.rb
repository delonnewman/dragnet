RailsLiveReload.configure do |config|
  # config.url = "/rails/live/reload"

  config.watch %r{app/views/.+\.(erb|haml)$}
  config.watch %r{(app|vendor)/(assets|javascript)/\w+/(.+\.(css|scss|js|html|png|jpg|cljs|cljc)).*}, reload: :always
  config.watch %r{app/helpers/.+\.rb}, reload: :always
  config.watch %r{app/presenters/.+\.rb}, reload: :always

  # Watch locales:
  # config.watch %r{config/locales/.+\.yml}, reload: :always

  # config.enabled = Rails.env.development?
end if defined?(RailsLiveReload)