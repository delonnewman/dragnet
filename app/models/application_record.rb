class ApplicationRecord < ActiveRecord::Base
  # instance-level application model extentions
  include Dragnet

  # class-level application model extentions
  extend Dragnet::Advising
  extend Dragnet::Generation

  primary_abstract_class
end
