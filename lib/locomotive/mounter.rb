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
require 'locomotive/mounter/models/content_type'
require 'locomotive/mounter/models/content_field'
require 'locomotive/mounter/models/content_entry'
require 'locomotive/mounter/reader/file_system'
require 'locomotive/mounter/reader/file_system/base'
require 'locomotive/mounter/reader/file_system/site_builder'
require 'locomotive/mounter/reader/file_system/pages_builder'
require 'locomotive/mounter/reader/file_system/snippets_builder'
require 'locomotive/mounter/reader/file_system/content_types_builder'

module Locomotive

  module Mounter

    @@logger = Logger.new(STDOUT).tap { |log| log.level = Logger::DEBUG }

    @@mount_point = nil

    # default locale
    @@locale = I18n.locale

    def self.mount(options)
      @@mount_point = Locomotive::Mounter::Config[:reader].run!(options)
    end

    def self.logger
      @@logger
    end

    def self.logger=(logger)
      @@logger = logger
    end

    def self.locale
      @@locale
    end

    def self.locale=(locale)
      @@locale = locale
    end

    def self.with_locale(locale, &block)
      tmp, @@locale = @@locale, locale.try(:to_sym) || @@locale
      yield
      @@locale = tmp
    end

  end

end