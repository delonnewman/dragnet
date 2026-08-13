# frozen_string_literal: true

module Dragnet::Views
end

module Dragnet::Components
  extend Phlex::Kit
end

Rails.autoloaders.main.push_dir(
  Rails.root.join("app/views"), namespace: Dragnet::Views
)

Rails.autoloaders.main.push_dir(
  Rails.root.join("app/components"), namespace: Dragnet::Components
)
