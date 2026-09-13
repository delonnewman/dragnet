module Dragnet::Types
end

module Dragnet::Ext
end

Rails.autoloaders.main.push_dir(
  Rails.root.join("app/extensions"), namespace: Dragnet::Ext
)

Rails.autoloaders.main.push_dir(
  Rails.root.join("app/types"), namespace: Dragnet::Types
)

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/types")
    Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/extensions")
  end
end
