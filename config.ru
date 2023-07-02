# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
Rails.application.load_server

error_logger = ActiveSupport::Logger.new("log/error.log")
error_logger.level = Logger::ERROR
Rails.logger.extend ActiveSupport::Logger.broadcast(error_logger)