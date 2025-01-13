unless Rails.application.config.eager_load
  Rails.logger.info "Preloading types..."
  dirs = [
    "#{Rails.root}/app/models/dragnet/types",
    "#{Rails.root}/app/extensions"
  ]

  Rails.application.config.to_prepare do
    dirs.each do |dir|
      Rails.autoloaders.main.eager_load_dir(dir)
    end
  end
end
