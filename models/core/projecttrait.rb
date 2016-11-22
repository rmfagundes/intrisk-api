require 'neo4j'
require_relative '../workflow/core/projecttrait'
require_relative '../policies/core/projecttrait_save'
module Models
  module Core
    # Project Trait
    class ProjectTrait
      include Neo4j::ActiveNode
      include Neo4j::Timestamps
      prepend Models::Workflow::Core::ProjectTraitInterceptor

      property :name, index: :exact, constraint: :unique
      property :language
      property :description

      has_many :in, :project, type: :presents, model_class: 'Project'

      has_many :both, :translations, rel_class: 'ProjectTraitTranslation'
      has_many :both, :synonyms, rel_class: 'ProjectTraitSynonym'

      def build_attributes(hashed = [], raw = nil)
        hashed.each do |key, value|
          send("#{key}=", value) if respond_to?(key)
        end
        self.raw = raw.nil? ? to_json : raw
      end

      def wflow_engine
        wflow_file = 'conf/workflow/core/projecttrait.yml'
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

    # Association class indicating a translation relationship
    # between nodes
    class ProjectTraitTranslation
      include Neo4j::ActiveRel

      from_class ProjectTrait
      to_class   ProjectTrait
      type 'TRANSLATES_TO'

      def insert
        save
      end

      def update
        save
      end

      def remove
        destroy
      end
    end

    # Association class indicating a synonym relationship
    # between nodes
    class ProjectTraitSynonym
      include Neo4j::ActiveRel

      from_class ProjectTrait
      to_class   ProjectTrait
      type 'IS_SYNONYM_OF'

      def insert
        save
      end

      def update
        save
      end

      def remove
        destroy
      end
    end
  end
end
