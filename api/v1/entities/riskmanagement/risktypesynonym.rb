# encoding: utf-8
module Entities
  module RiskManagement
    module RiskTypeSynonym
      # Default representation for the domain class RiskType
      class Default < Grape::Entity
        expose :id,
               documentation: { type: 'string',
                                desc: 'ID da relação de sinonimia',
                                required: true }
      end
    end
  end
end
