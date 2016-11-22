require 'neo4j'
require_relative '../core/role'
require_relative '../workflow/riskmanagement/risktype'
require_relative '../policies/riskmanagement/risktype_save'
module Models
  module RiskManagement
    # Risk Type (intended to work like tags)
    class RiskType
      include Neo4j::ActiveNode
      include Neo4j::Timestamps
      prepend Models::Workflow::RiskManagement::RiskTypeInterceptor

      property :name, index: :exact, constraint: :unique
      property :language
      property :raw
      property :status

      has_many :in, :risks, type: :of_type, model_class: 'Risk'

      has_many :both, :translations, rel_class: 'RiskTypeTranslation'
      has_many :both, :synonyms, rel_class: 'RiskTypeSynonym'

      def build_attributes(hashed = [], raw = nil)
        hashed.each do |key, value|
          send("#{key}=", value) if respond_to?(key)
        end
        self.raw = raw.nil? ? to_json : raw
      end

      def wflow_engine
        wflow_file = 'conf/workflow/riskmanagement/risktype.yml'
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

      def find_by_role(_role_name)
        { names: ['Rodrigo'], emails: ['admin.intrisk@inanimind.com'] }
        # people = Models::Core::Role.find_people_by_role_name role_name
        # result = { names: [], emails: [] }
        # return result if people.nil?
        # people.each do |person|
        #   result[:names].push person.name
        #   result[:emails].push person.email
        # end
        # result
      end
    end

    # Association class indicating a translation relationship
    # between nodes
    class RiskTypeTranslation
      include Neo4j::ActiveRel

      from_class 'RiskType'
      to_class   'RiskType'
      type       'TRANSLATES_TO'

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
    class RiskTypeSynonym
      include Neo4j::ActiveRel

      from_class 'Models::RiskManagement::RiskType'
      to_class   'Models::RiskManagement::RiskType'
      type       'IS_SYNONYM_OF'

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
