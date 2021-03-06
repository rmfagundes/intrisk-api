require_relative '../../../modules/workflow'
module Models
  module Workflow
    module RiskManagement
      # Risk Type workflow interceptor
      module RiskTypeInterceptor
        def insert
          wflow_engine.exec(self, 'init')
          super
        end

        def update
          wflow_engine.exec(self, 'save')
          super
        end

        def act(action)
          wflow_engine.exec(self, action)
          super
        end

        def remove
          wflow_engine.exec(self, 'remove')
          super
        end
      end
    end
  end
end
