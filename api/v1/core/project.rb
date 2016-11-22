require_relative '../../../models/core/project'
require_relative '../../../models/policies/core/projectsecurity'
require_relative '../../../modules/neo4j'
require_relative '../../../modules/workflow'
require_relative '../../../modules/security'
require_relative '../entities/core/project'

module API
  module V1
    module Core
      # REST API method exposing
      class Project < Grape::API
        resources :projects do
          include Modules::Neo4jConnector
          include Modules::Workflow

          after_validation do
            # Transactional by default. If overriding needed
            # define @transactional = false on initialize
            Modules::Neo4jConnector.open_session

            Modules::Security.authenticate
          end

          after do
            Modules::Neo4jConnector.close_session
          end

          desc 'Obtém uma lista de projetos, de acordo com as '\
               'credenciais do usuário' do
            entity Entities::Core::Project::Description
          end
          get do
            present Models::Core::Project.all,
                    with: Project.entity_switcher(params)
          end

          desc 'Obtém um projeto, pelo ID informado, de acordo '\
               'com as credenciais do usuário' do
            entity Entities::Core::Projeto::Description
          end
          get ':id' do
            present Models::Core::Project.find(params[:id]),
                    with: Project.entity_switcher(params)
          end

          desc 'Grava um novo projeto' do
            entity Entities::Core::Project::Description
            http_codes [[500, 'Falha ao gravar o registro']]
          end
          params do
            requires :project, documentation: { param_type: 'body' },
                               description: 'JSON do projeto'
          end
          post do
            projeto = Models::Core::Project.new
            projeto.build_attributes(params[:project])
            projeto.save
            status 201
            header 'Location', "/projetos/#{projeto.id}"
            present projeto, with: Project.entity_switcher(params)
          end

          desc 'Atualiza um projeto, pelo ID, de acordo com as '\
               'credenciais do usuário' do
            entity Entities::Core::Project::Description
            http_codes [[500, 'Falha ao gravar o registro']]
          end
          params do
            requires :project, documentation: { param_type: 'body' },
                               description: 'JSON do projeto'
          end
          put ':id' do
            projeto = Models::Core::Project.find(params[:id])
            if projeto.nil?
              status 201
              header 'Location', "/tipos/#{projeto.id}"
              projeto = Models::Core::Project.new
            else
              status 200
            end
            projeto.build_attributes(params[:project])
            projeto.save
            present projeto, with: Project.entity_switcher(params)
          end

          desc 'Atualiza um projeto, pelo ID, de acordo com as '\
               'credenciais do usuário' do
            entity Entities::Core::Project::Description
            http_codes [[500, 'Falha ao gravar o registro']]
          end
          params do
            requires :project, documentation: { param_type: 'body' },
                               description: 'JSON do projeto'
          end
          patch ':id' do
            projeto = Models::Core::Project.find(params[:id])

            if projeto.nil?
              status 404
              present nil
            else
              projeto.build_attributes(params[:project])
              projeto.save
              status 200
              present projeto, with: Project.entity_switcher(params)
            end
          end

          desc 'Remove um projeto, pelo ID, de acordo com as '\
               'credenciais do usuário' do
            entity Entities::Core::Project::Description
            http_codes [[500, 'Falha ao apagar o registro']]
          end
          delete ':id' do
            status 204
            projeto = Models::Core::Project.find(params[:id])
            projeto.destroy
          end

          def entity_switcher(_param = nil)
            Entities::Core::Project::Description
          end
        end
      end
    end
  end
end
