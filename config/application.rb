require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'

Bundler.require(*Rails.groups)

require_relative '../lib/dragnet'

module Dragnet
  class Application < Rails::Application
    config.load_defaults 7.0

    config.time_zone = 'Mountain Time (US & Canada)'

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.active_record.use_yaml_unsafe_load = true # FIXME: failing on symbol keys without this
    # ActiveRecord
    # config.active_record.yaml_column_permitted_classes = [
    #   TrueClass,
    #   FalseClass,
    #   NilClass,
    #   Integer,
    #   Float,
    #   String,
    #   Symbol,
    #   Array,
    #   Hash,
    #   Time,
    #   DateTime,
    #   ActiveRecord::Base,
    #   ActiveSupport::HashWithIndifferentAccess,
    # ]
  end
end
