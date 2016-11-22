require_relative '../../../exception/policy_exception'
module Models
  module Policies
    module Core
      # Interceptor class for security validations
      class RoleSave
        def run(model)
          failure = []
          failure.push 'Name required' if model.name.nil? || model.name.empty?
          raise PolicyException, failure unless failure.empty?
        end
      end
    end
  end
end
