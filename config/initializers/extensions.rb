module Dragnet
  module Ext
  end
end

Rails.autoloaders.main.push_dir("#{Rails.root}/app/extensions", namespace: Dragnet::Ext)
