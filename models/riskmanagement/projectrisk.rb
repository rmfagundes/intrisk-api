require_relative '../core/project'
module Models
  module RiskManagement
    # Class that relates risks to a managed project
    class ProjectRisk
      include Neo4j::ActiveRel

      from_class 'Risk'
      to_class   'Model::Core::Project'
      type 'IMPACTS_ON'

      property :probability, type: Integer
      property :impact_rate_estimated, type: Integer
      property :impact_rate_real, type: Integer
    end
  end
end
