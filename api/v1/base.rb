# encoding: UTF-8
require_relative './riskmanagement/risk'
require_relative './riskmanagement/risktype'
require_relative './riskmanagement/risktypesynonym'
module API
  module V1
    # Base class for mounting the V1 of the API
    class Base < Grape::API
      version 'v1', using: :header, vendor: 'inanimind', format: :json
      format :json
      content_type :json, 'application/json'

      mount API::V1::RiskManagement::Risk
      mount API::V1::RiskManagement::RiskType
      mount API::V1::RiskManagement::RiskTypeSynonym

      add_swagger_documentation(api_version: 'v1', hide_format: true,
                                hide_documentation_path: true)
    end
  end
end
