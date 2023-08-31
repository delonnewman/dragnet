module Dragnet
  class ApplicationRecord < ActiveRecord::Base
    # instance-level application model extentions
    include Memoizable

    # class-level application model extensions
    extend Advising
    extend Generation

    primary_abstract_class
  end
end
