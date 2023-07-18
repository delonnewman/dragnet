# frozen_string_literal: true

require 'set'

require 'faker'
require 'active_support'
require 'active_record'

require_relative 'dragnet/constants'
require_relative 'dragnet/predicates'
require_relative 'dragnet/utils'
require_relative 'dragnet/core_ext'
require_relative 'dragnet/class_meta_data'
require_relative 'dragnet/memoizable'

require_relative 'dragnet/time_utils'
require_relative 'dragnet/composed'
require_relative 'dragnet/command'
require_relative 'dragnet/advising'
require_relative 'dragnet/advice'
require_relative 'dragnet/policy'
require_relative 'dragnet/query'

# Generators
require_relative 'dragnet/generator'
require_relative 'dragnet/parameterized_generator'
require_relative 'dragnet/generators'
require_relative 'dragnet/active_record_generator'
require_relative 'dragnet/generation'

# View Layer
require_relative 'dragnet/view/presenter'
require_relative 'dragnet/view/paged_presenter'

module Dragnet
  GITHUB_URL = 'https://github.com/delonnewman/dragnet/'
  private_constant :GITHUB_URL

  # Return the GitHub url of the project.
  #
  # @return [Addressable::URI]
  def self.github_url
    @github_url ||= Addressable::URI.parse(GITHUB_URL)
  end

  # Return the current version of the system (based on git SHA).
  #
  # @return [String, nil]
  def self.version
    current_git_sha[0, 8]
  end

  # Return the current git SHA hash.  It will first look for the GIT_SHA environment variable
  # if this is not set then it will attempt to get the latest hash from git.
  #
  # @return [String]
  def self.current_git_sha
    @current_git_sha ||= ENV.fetch('GIT_SHA') { `git log -n 1 --format="%H"` } # use latest git hash as version
  end

  # Return the current release of the system (see RELEASE.txt in project root)
  #
  # @return [String]
  def self.release
    Rails.root.join('RELEASE.txt').read
  end
end
