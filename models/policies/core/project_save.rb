require_relative '../../../exception/policy_exception'
module Models
  module Policies
    module Core
      # Interceptor class for security validations
      class ProjectSave
        def run(model)
          failure = []
          failure.push 'Name required' if model.name.nil? || model.name.empty?
          if model.language.nil? || model.language.empty?
            failure.push 'Language required'
          end
          raise PolicyException, failure unless failure.empty?
        end
      end
    end
  end
end
