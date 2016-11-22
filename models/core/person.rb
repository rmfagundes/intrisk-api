require 'neo4j'
require_relative '../workflow/core/person'
require_relative '../policies/core/person_save'
module Models
  module Core
    # Person
    class Person
      include Neo4j::ActiveNode
      include Neo4j::Timestamps
      prepend Models::Workflow::Core::PersonInterceptor

      property :name, index: :exact, constraint: :unique
      property :language
      property :login
      property :email
      property :password
      property :avatar

      has_many :in, :teams, rel_class: TeamRole
      has_many :in, :company, rel_class: CompanyRole

      has_many :out, :roles, type: :presents,
                             model_class: 'Model::Core::Role'

      def build_attributes(hashed = [], raw = nil)
        hashed.each do |key, value|
          send("#{key}=", value) if respond_to?(key)
        end
        self.raw = raw.nil? ? to_json : raw
      end

      def wflow_engine
        wflow_file = 'conf/workflow/core/person.yml'
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
