$:.unshift File.expand_path(File.dirname(__FILE__))

# Force encoding to UTF-8
Encoding.default_internal = Encoding.default_external = 'UTF-8'

require 'logger'
require 'colorize'

require 'active_support'
require 'active_support/core_ext'
require 'stringex'
require 'tempfile'
require 'digest/sha1'
require 'chronic'

require 'tilt'
require 'sprockets'
require 'sprockets-sass'
require 'haml'
require 'compass'

require 'httmultiparty'
require 'mime/types'

# Utils
require 'locomotive/mounter/utils/hash'
require 'locomotive/mounter/utils/yaml'
require 'locomotive/mounter/utils/string'
require 'locomotive/mounter/utils/output'
require 'locomotive/mounter/utils/yaml_front_matters_template'

# Main
require 'locomotive/mounter/version'
require 'locomotive/mounter/exceptions'
require 'locomotive/mounter/config'
require 'locomotive/mounter/fields'
require 'locomotive/mounter/mounting_point'
require 'locomotive/mounter/engine_api'

# Extensions
require 'locomotive/mounter/extensions/httmultiparty'
require 'locomotive/mounter/extensions/sprockets'
require 'locomotive/mounter/extensions/compass'
require 'locomotive/mounter/extensions/tilt/css'

# Models
require 'locomotive/mounter/models/base'
Dir[File.join(File.dirname(__FILE__), 'mounter/models', '*.rb')].each { |lib| require lib }

# Readers: Filesystem / API
require 'locomotive/mounter/reader/runner'
require 'locomotive/mounter/reader/file_system'
require 'locomotive/mounter/reader/api'

# Writer: Filesystem
require 'locomotive/mounter/writer/runner'
require 'locomotive/mounter/writer/file_system'
require 'locomotive/mounter/writer/api'

module Locomotive

  module Mounter

    TEMPLATE_EXTENSIONS = %w(liquid haml)

    @@logger = ::Logger.new(STDOUT).tap { |log| log.level = ::Logger::DEBUG }

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
      @@locale = locale.to_sym
    end

    def self.with_locale(locale, &block)
      tmp, @@locale = @@locale, locale.try(:to_sym) || @@locale
      yield.tap do
        @@locale = tmp
      end
    end

  end

end