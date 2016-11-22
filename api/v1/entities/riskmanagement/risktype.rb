# encoding: utf-8
module Entities
  module RiskManagement
    module RiskType
      # Default representation for the domain class RiskType
      class Description < Grape::Entity
        expose :name,
               documentation: { type: 'string',
                                desc: 'Nome do tipo de risco',
                                required: true }
        expose :language,
               documentation: { type: 'string',
                                desc: 'Idioma do tipo de risco',
                                required: true }
      end
    end
  end
end
