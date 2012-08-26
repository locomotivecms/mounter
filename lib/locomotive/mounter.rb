$:.unshift File.expand_path(File.dirname(__FILE__))

require 'logger'

require 'active_support'
require 'active_support/core_ext'

require 'tilt'
require 'haml'
require 'compass'

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
require 'locomotive/mounter/models/theme_asset'

require 'locomotive/mounter/extensions/compass'
require 'locomotive/mounter/extensions/tilt/template'
require 'locomotive/mounter/extensions/tilt/css'
require 'locomotive/mounter/extensions/tilt/haml'
require 'locomotive/mounter/extensions/tilt/liquid'

require 'locomotive/mounter/utils/template'
require 'locomotive/mounter/utils/hash'
require 'locomotive/mounter/utils/yaml'

require 'locomotive/mounter/reader/file_system'
require 'locomotive/mounter/reader/file_system/base'
require 'locomotive/mounter/reader/file_system/site_builder'
require 'locomotive/mounter/reader/file_system/pages_builder'
require 'locomotive/mounter/reader/file_system/snippets_builder'
require 'locomotive/mounter/reader/file_system/content_types_builder'
require 'locomotive/mounter/reader/file_system/content_entries_builder'
require 'locomotive/mounter/reader/file_system/theme_assets_builder'

require 'locomotive/mounter/writer/base/runner'
require 'locomotive/mounter/writer/file_system'
require 'locomotive/mounter/writer/file_system/base'
require 'locomotive/mounter/writer/file_system/site_writer'
require 'locomotive/mounter/writer/file_system/pages_writer'
require 'locomotive/mounter/writer/file_system/snippets_writer'
require 'locomotive/mounter/writer/file_system/content_types_writer'
require 'locomotive/mounter/writer/file_system/content_entries_writer'
require 'locomotive/mounter/writer/file_system/theme_assets_writer'

# Force encoding to UTF-8
Encoding.default_internal = Encoding.default_external = 'UTF-8'

module Locomotive

  module Mounter

    TEMPLATE_EXTENSIONS = %w(liquid haml)

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