$:.unshift File.expand_path(File.dirname(__FILE__))

require 'active_support'

require 'locomotive/mounter/version'
require 'locomotive/mounter/config'
require 'locomotive/mounter/mounting_point'
require 'locomotive/mounter/models/site'
require 'locomotive/mounter/models/page'
require 'locomotive/mounter/reader/file_system'

module Locomotive

  module Mounter

    @@mount_point = nil

    def self.mount(options)
      @@mount_point = Locomotive::Mounter::Config[:reader].run!(options)
    end

  end

end