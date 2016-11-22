$LOAD_PATH.unshift './app'

require 'rack/cors'

require 'rubygems'
require 'grape'
require 'rack'
require 'grape-entity'
require 'grape-swagger'
require 'neo4j'
require 'net/smtp'

require_relative 'api/base.rb'

# config.neo4j.session_options =
# { basic_auth: { username: 'neo4j', password: 'inanimindPWD' } }
# config.neo4j.session_type = :server_db
# config.neo4j.session_path = 'http://localhost:7474'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :put, :delete,
                                           :options, :patch]
  end
end

run API::Base
