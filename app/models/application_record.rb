class ApplicationRecord < ActiveRecord::Base
  # instance-level application model extentions
  include Dragnet
  include Dragnet::Memoizable

  # class-level application model extentions
  extend Dragnet::Advising
  extend Dragnet::Generation

  primary_abstract_class
end
