require 'neo4j'
require_relative '../workflow/core/team'
require_relative '../policies/core/team_save'
module Models
  module Core
    # Team
    class Team
      include Neo4j::ActiveNode
      include Neo4j::Timestamps
      prepend Models::Workflow::Core::TeamInterceptor

      property :name, index: :exact, constraint: :unique
      property :language

      has_many :out, :members, rel_class: 'TeamRole'

      has_one :in, :company, type: :divides_into, model_class: 'Company'

      def build_attributes(hashed = [], raw = nil)
        hashed.each do |key, value|
          send("#{key}=", value) if respond_to?(key)
        end
        self.raw = raw.nil? ? to_json : raw
      end

      def wflow_engine
        wflow_file = 'conf/workflow/core/team.yml'
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

    # Association class that links roles to teams
    class TeamRole
      include Neo4j::ActiveRel

      from_class 'Team'
      to_class   'Person'
      type 'GATHER'

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
