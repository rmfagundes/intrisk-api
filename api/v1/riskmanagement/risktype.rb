require_relative '../../../models/riskmanagement/risktype'
require_relative '../../../modules/neo4j'
require_relative '../../../modules/security'
require_relative '../entities/riskmanagement/risktype'

module API
  module V1
    module RiskManagement
      # REST API method exposing
      class RiskType < Grape::API
        # TODO. Multiplas pesquisas            [?] ON DEMAND
        # TODO. [module] Autenticacao (JWT)    [2]
        # TODO. Link entre workflows           [?] ON DEMAND
        # TODO. Criar demais endpoints         [1]
        # TODO. Logging com ELK ou algum SaaS  [3]
        resources :risktypes do
          include Modules::Neo4jConnector

          after_validation do
            Modules::Security.authenticate
            # Transactional by default. If overriding needed
            # pass FALSE as parameter
            Modules::Neo4jConnector.open_session
          end

          after do
            Modules::Neo4jConnector.close_session
          end

          desc 'Obtém uma lista de tipos de risco, de acordo com as '\
               'credenciais do usuário' do
            entity Entities::RiskManagement::RiskType::Description
          end
          get do
            present Models::RiskManagement::RiskType.all,
                    with: RiskType.entity_switcher(params)
          end

          desc 'Obtém um tipo de risco, pelo ID informado, de acordo '\
               'com as credenciais do usuário' do
            entity Entities::RiskManagement::RiskType::Description
          end
          get ':id' do
            present Models::RiskManagement::RiskType.find(params[:id]),
                    with: RiskType.entity_switcher(params)
          end

          desc 'Grava um novo tipo de risco' do
            entity Entities::RiskManagement::RiskType::Description
            http_codes [[500, 'Falha ao gravar o registro']]
          end
          params do
            requires :risk_type, documentation: { param_type: 'body' },
                                 description: 'JSON do tipo de risco'
          end
          post do
            begin
              tipo = Models::RiskManagement::RiskType.new
              tipo.build_attributes(params[:risk_type])
              tipo.insert
              status 201
              header 'Location', "/tipos/#{tipo.id}"
              present tipo, with: RiskType.entity_switcher(params)
            rescue RuntimeError => e
              Modules::Neo4jConnector.rollback
              status 500
              present e.message
            end
          end

          desc 'Atualiza um tipo de risco, pelo ID, de acordo com as '\
               'credenciais do usuário' do
            entity Entities::RiskManagement::RiskType::Description
            http_codes [[500, 'Falha ao gravar o registro']]
          end
          params do
            requires :risk_type, documentation: { param_type: 'body' },
                                 description: 'JSON do tipo de risco'
          end
          put ':id' do
            begin
              tipo = Models::RiskManagement::RiskType.find(params[:id])
              if tipo.nil?
                status 201
                header 'Location', "/tipos/#{tipo.id}"
                tipo = Models::RiskManagement::RiskType.new
              else
                status 200
              end
              tipo.build_attributes(params[:risk_type])
              tipo.update
              present tipo, with: RiskType.entity_switcher(params)
            rescue RuntimeError => e
              Modules::Neo4jConnector.rollback
              status 500
              present e.message
            end
          end

          desc 'Atualiza um tipo de risco, pelo ID, de acordo com as '\
               'credenciais do usuário' do
            entity Entities::RiskManagement::RiskType::Description
            http_codes [[500, 'Falha ao gravar o registro']]
          end
          params do
            requires :risk_type, documentation: { param_type: 'body' },
                                 description: 'JSON do tipo de risco'
          end
          patch ':id' do
            begin
              tipo = Models::RiskManagement::RiskType.find(params[:id])

              if tipo.nil?
                status 404
                present nil
              else
                tipo.build_attributes(params[:risk_type])
                tipo.act(params[:risk_type][:action])
                status 200
                present tipo, with: RiskType.entity_switcher(params)
              end
            rescue RuntimeError => e
              Modules::Neo4jConnector.rollback
              status 500
              present e.message
            end
          end

          desc 'Remove um tipo de risco, pelo ID, de acordo com as '\
               'credenciais do usuário' do
            entity Entities::RiskManagement::RiskType::Description
            http_codes [[500, 'Falha ao apagar o registro']]
          end
          delete ':id' do
            begin
              status 204
              tipo = Models::RiskManagement::RiskType.find(params[:id])
              tipo.remove
            rescue RuntimeError => e
              Modules::Neo4jConnector.rollback
              status 500
              present e.message
            end
          end

          def entity_switcher(_param = nil)
            Entities::RiskManagement::RiskType::Description
          end
        end
      end
    end
  end
end
