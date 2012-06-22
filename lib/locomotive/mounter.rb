$:.unshift File.expand_path(File.dirname(__FILE__))

require 'logger'

require 'active_support'
require 'active_support/core_ext'

require 'locomotive/mounter/version'
require 'locomotive/mounter/exceptions'
require 'locomotive/mounter/config'
require 'locomotive/mounter/fields'
require 'locomotive/mounter/mounting_point'
require 'locomotive/mounter/models/base'
require 'locomotive/mounter/models/site'
require 'locomotive/mounter/models/page'
require 'locomotive/mounter/models/snippet'
require 'locomotive/mounter/reader/file_system'
require 'locomotive/mounter/reader/file_system/base'
require 'locomotive/mounter/reader/file_system/site_builder'
require 'locomotive/mounter/reader/file_system/pages_builder'
require 'locomotive/mounter/reader/file_system/snippets_builder'

module Locomotive

  module Mounter

    @@logger = Logger.new(STDOUT).tap { |log| log.level = Logger::DEBUG }

    @@mount_point = nil

    def self.mount(options)
      @@mount_point = Locomotive::Mounter::Config[:reader].run!(options)
    end

    def self.logger
      @@logger
    end

    def self.logger=(logger)
      @@logger = logger
    end

  end

end