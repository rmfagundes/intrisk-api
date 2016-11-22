require 'neo4j'
require_relative '../workflow/core/company'
require_relative '../policies/core/company_save'
module Models
  module Core
    # Company
    class Company
      include Neo4j::ActiveNode
      include Neo4j::Timestamps
      prepend Models::Workflow::Core::CompanyInterceptor

      property :name, index: :exact, constraint: :unique
      property :language
      property :industry
      property :logo
      property :locationCity
      property :locationProvince
      property :locationCountry

      has_many :out, :teams, type: :divides_into, model_class: 'Team'
      has_many :out, :people, rel_class: 'CompanyRole'
      has_many :out, :project, type: :possess, model_class: 'Project'

      def build_attributes(hashed = [], raw = nil)
        hashed.each do |key, value|
          send("#{key}=", value) if respond_to?(key)
        end
        self.raw = raw.nil? ? to_json : raw
      end

      def wflow_engine
        wflow_file = 'conf/workflow/core/company.yml'
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

    # Association class that designates company roles to people
    class CompanyRole
      include Neo4j::ActiveRel

      from_class 'Company'
      to_class   'Person'
      type 'HIRE'

      property :role

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
