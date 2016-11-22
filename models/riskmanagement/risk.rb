require_relative 'projectrisk'
require_relative '../workflow/riskmanagement/risk'
require_relative '../policies/riskmanagement/risk_save'
module Models
  module RiskManagement
    # Risks
    class Risk
      include Neo4j::ActiveNode
      include Neo4j::Timestamps
      prepend Models::Workflow::RiskManagement::RiskInterceptor

      property :name, index: :exact, constraint: :unique
      property :language

      has_many :out, :type, type: :of_type, model_class: 'RiskType'
      has_many :out,
               :project,
               type: :impacts_on,
               model_class: 'Models::RiskManagement::ProjectRisk'

      has_many :both, :translations, rel_class: 'RiskTranslation'
      has_many :both, :synonyms, rel_class: 'RiskSynonym'

      def build_attributes(hashed = [], raw = nil)
        hashed.each do |key, value|
          send("#{key}=", value) if respond_to?(key)
        end
        self.raw = raw.nil? ? to_json : raw
      end

      def wflow_engine
        wflow_file = 'conf/workflow/riskmanagement/risk.yml'
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
    class RiskTranslation
      include Neo4j::ActiveRel

      from_class 'Risk'
      to_class   'Risk'
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
    class RiskSynonym
      include Neo4j::ActiveRel

      from_class 'Risk'
      to_class   'Risk'
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
