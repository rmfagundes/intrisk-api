require 'neo4j'
require_relative '../workflow/core/role'
require_relative '../policies/core/role_save'
module Models
  module Core
    # User-role
    class Role
      include Neo4j::ActiveNode
      include Neo4j::Timestamps
      prepend Models::Workflow::Core::RoleInterceptor

      property :name, index: :exact, constraint: :unique
      property :description
      property :status

      has_many :out, :users, type: :presents, model_class: 'Person'

      def build_attributes(hashed = [], raw = nil)
        hashed.each do |key, value|
          send("#{key}=", value) if respond_to?(key)
        end
        self.raw = raw.nil? ? to_json : raw
      end

      def wflow_engine
        wflow_file = 'conf/workflow/core/role.yml'
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

      def self.find_people_by_role_name(_role_name)
        # TODO.
      end
    end
  end
end
