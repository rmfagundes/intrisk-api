# encoding: UTF-8
require_relative './v1/base'

module API
  # Base class for API mounting
  class Base < Grape::API
    mount API::V1::Base
  end
end
