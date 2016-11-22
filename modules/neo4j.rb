module Modules
  # Module responsible for enabling connection to a neo4j instance
  module Neo4jConnector
    def self.open_session(transactional = true)
      @neo4j_config = YAML.load_file('conf/neo4j.yml')
      @session = Neo4j::Session.open(:server_db, @neo4j_config[:url],
                                     basic_auth: @neo4j_config[:basic_auth])
      @tx = Neo4j::Transaction.new if transactional
    end

    def self.close_session
      @tx.close unless @tx.nil?
      @session.close
    end

    def self.rollback
      @tx.mark_failed
    end
  end
end
