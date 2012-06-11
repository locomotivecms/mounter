require 'logger'

logfile = File.join(File.dirname(__FILE__), '..', 'tmp', 'trace.log')

Locomotive::Mounter.logger = ::Logger.new(logfile).tap do |log|
  log.level = Logger::DEBUG
end