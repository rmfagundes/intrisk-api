require 'neo4j'
require_relative '../workflow/core/project'
require_relative '../policies/core/project_save'
require_relative './projecttrait'
module Models
  module Core
    # Project
    class Project
      include Neo4j::ActiveNode
      include Neo4j::Timestamps
      prepend Models::Workflow::Core::ProjectInterceptor

      property :alias, index: :exact
      property :name
      property :description
      property :endDate
      property :industry
      property :locationCity
      property :locationProvince
      property :locationCountry
      property :language

      has_many :in, :risks, rel_class: 'ProjectRisk'

      has_many :out, :traits, type: :presents,
                              model_class: 'Model::Core::ProjectTrait'
      has_one :in, :company, type: :possess, model_class: 'Company'

      def build_attributes(hashed = [], raw = nil)
        hashed.each do |key, value|
          send("#{key}=", value) if respond_to?(key)
        end
        self.raw = raw.nil? ? to_json : raw
      end

      def wflow_engine
        wflow_file = 'conf/workflow/core/project.yml'
        @wflow = Modules::Workflow.new(wflow_file) if @wflow.nil?
      end

      def insert
        save
      end

      def update
        save
      end

      def act(params)
        build_attributes(params) # For now, works exactly like update
        save
      end

      def remove
        destroy
      end
    end
  end
end
