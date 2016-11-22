require_relative '../../../models/riskmanagement/risk'
require_relative '../../../modules/neo4j'
require_relative '../../../modules/workflow'
# require_relative '../entities/riskmanagement/risk'

module API
  module V1
    module RiskManagement
      # REST API method exposing
      class Risk < Grape::API
        resources :risks do
          get do
            'Lista de Riscos.'
          end
        end
      end
    end
  end
end
