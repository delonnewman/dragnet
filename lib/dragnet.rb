# frozen_string_literal: true

require 'set'

require 'faker'
require 'active_support'
require 'active_record'

require_relative 'dragnet/constants'
require_relative 'dragnet/utils'
require_relative 'dragnet/core_ext'
require_relative 'dragnet/self_describing'
require_relative 'dragnet/memoizable'

require_relative 'dragnet/time_utils'
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
