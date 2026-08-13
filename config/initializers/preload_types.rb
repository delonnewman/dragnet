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
