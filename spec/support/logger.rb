require 'logger'
require 'fileutils'

log_dir = File.join(File.dirname(__FILE__), '..', 'tmp')

RSpec.configure do |c|
  c.before(:suite) do
    FileUtils::mkdir_p  log_dir
    logfile = File.join(log_dir, 'trace.log')
    Locomotive::Mounter.logger = ::Logger.new(logfile).tap do |log|
    log.level = Logger::DEBUG
  end

  end
  c.after(:suite) do
    FileUtils.rm_rf Dir[log_dir]
  end
end