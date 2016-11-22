require_relative '../../../models/riskmanagement/risktype'
require_relative '../../../modules/neo4j'
require_relative '../../../modules/security'
require_relative '../entities/riskmanagement/risktypesynonym'

module API
  module V1
    module RiskManagement
      # REST API method exposing
      class RiskTypeSynonym < Grape::API
        resources :risktypesynonym do
          include Modules::Neo4jConnector

          after_validation do
            Modules::Security.authenticate
            # Transactional by default. If overriding needed
            # define @transactional = false on initialize
            Modules::Neo4jConnector.open_session
          end

          after do
            Modules::Neo4jConnector.close_session
          end

          desc 'Obtém uma lista de tipos de risco sinônimos do risco '\
               'identificado pelo ID informado, de acordo com as '\
               'credenciais do usuário' do
            entity Entities::RiskManagement::RiskType::Description
          end
          get ':id' do
            present Models::RiskManagement::RiskType.find(params[:id]),
                    with: RiskType.entity_switcher(params)
          end

          desc 'Grava uma associacao entre tipos de risco' do
            entity Entities::RiskManagement::RiskType::Description
            http_codes [[500, 'Falha ao gravar o registro']]
          end
          params do
            requires :id_from, documentation: { param_type: 'query' },
                               description: 'Tipo de risco de origem'
            requires :id_to, documentation: { param_type: 'query' },
                             description: 'Tipo de risco a que se relaciona'
          end
          post do
            begin
              synonymia = Models::RiskManagement::RiskTypeSynonym.new
              synonymia.from_node = Models::RiskManagement::RiskType
                                    .find(params[:id_from])
              synonymia.to_node = Models::RiskManagement::RiskType
                                  .find(params[:id_to])
              synonymia.insert
              status 201
              present synonymia, with: RiskTypeSynonym.entity_switcher(params)
            rescue RuntimeError => e
              Modules::Neo4jConnector.rollback
              status 500
              present e.message
            end
          end

          desc 'Atualiza uma relação de sinonímia entre tipos de risco, '\
               'pelo ID, de acordo com as credenciais do usuário' do
            entity Entities::RiskManagement::RiskType::Description
            http_codes [[500, 'Falha ao gravar o registro']]
          end
          params do
            requires :risk_type, documentation: { param_type: 'body' },
                                 description: 'JSON do tipo de risco'
          end
          put ':id' do
            begin
              synonymia = Models::RiskManagement::RiskTypeSynonym
                          .find(params[:id])
              if synonymia.nil?
                status 201
                synonymia = Models::RiskManagement::RiskTypeSynonym.new
              else
                status 200
              end
              synonymia.from_node = Models::RiskManagement::RiskType
                                    .find(params[:id_from])
              synonymia.to_node = Models::RiskManagement::RiskType
                                  .find(params[:id_to])
              synonymia.update
              present synonymia, with: RiskTypeSynonym.entity_switcher(params)
            rescue RuntimeError => e
              Modules::Neo4jConnector.rollback
              status 500
              present e.message
            end
          end

          desc 'Atualiza uma relação de sinonímia entre tipos de risco, '\
               'pelo ID, de acordo com as credenciais do usuário' do
            entity Entities::RiskManagement::RiskType::Description
            http_codes [[500, 'Falha ao gravar o registro']]
          end
          params do
            requires :risk_type, documentation: { param_type: 'body' },
                                 description: 'JSON do tipo de risco'
          end
          patch ':id' do
            begin
              synonymia = Models::RiskManagement::RiskTypeSynonym
                          .find(params[:id])
              if tipo.nil?
                status 404
                present nil
              else
                synonymia.from_node = Models::RiskManagement::RiskType
                                      .find(params[:id_from])
                synonymia.to_node = Models::RiskManagement::RiskType
                                    .find(params[:id_to])
                synonymia.update
                status 200
                present tipo, with: RiskTypeSynonym.entity_switcher(params)
              end
            rescue RuntimeError => e
              Modules::Neo4jConnector.rollback
              status 500
              present e.message
            end
          end

          desc 'Remove uma relação de sinonímia entre tipos de risco, '\
               'pelo ID, de acordo com as credenciais do usuário' do
            entity Entities::RiskManagement::RiskType::Description
            http_codes [[500, 'Falha ao apagar o registro']]
          end
          delete ':id' do
            begin
              status 204
              tipo = Models::RiskManagement::RiskTypeSynonym.find(params[:id])
              tipo.remove
            rescue RuntimeError => e
              Modules::Neo4jConnector.rollback
              status 500
              present e.message
            end
          end

          def entity_switcher(_param = nil)
            Entities::RiskManagement::RiskTypeSynonym::Default
          end
        end
      end
    end
  end
end
