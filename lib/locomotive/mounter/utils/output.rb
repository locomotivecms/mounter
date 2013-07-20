module Locomotive
  module Mounter
    module Utils
      module Output

        extend ActiveSupport::Concern

        included do

          @@buffer_enabled  = false
          @@buffer_log      = ''

        end

        protected

        # Print the the title for each kind of resource.
        #
        def output_title(action = :pushing)
          msg = "* #{action.to_s.capitalize} #{self.class.name.gsub(/(Writer|Reader)$/, '').demodulize}"
          self.log msg.colorize(background: :white, color: :black) + "\n"
        end

        # Print the current locale.
        #
        def output_locale
          locale = Locomotive::Mounter.locale.to_s
          self.log "  #{locale.colorize(background: :blue, color: :white)}\n"
        end

        def truncate(string, length = 50, separator = '[...]')
          if string.length > length
            string[0..(length - separator.length)] + separator
          else
            string
          end
        end

        # Print the message about the creation / update of a resource.
        #
        # @param [ Object ] resource The resource (Site, Page, ...etc).
        #
        def output_resource_op(resource)
          self.log self.resource_message(resource)
        end

        # Print the message about the creation / update of a resource.
        #
        # @param [ Object ] resource The resource (Site, Page, ...etc).
        # @param [ Symbol ] status :success, :error, :skipped
        # @param [ String ] errors The error messages
        #
        def output_resource_op_status(resource, status = :success, errors = nil)
          status_label = case status
          when :success         then 'done'.colorize(color: :green)
          when :error           then 'error'.colorize(color: :red)
          when :skipped         then 'skipped'.colorize(color: :magenta)
          when :same            then 'same'.colorize(color: :magenta)
          when :not_translated  then 'not translated (itself or parent)'.colorize(color: :yellow)
          end

          spaces = '.' * (80 - self.resource_message(resource).size)
          self.log "#{spaces}[#{status_label}]\n"

          if errors && status == :error
            self.log "#{errors.colorize(color: :red)}\n"
          end
        end

        # Return the message about the creation / update of a resource.
        #
        # @param [ Object ] resource The resource (Site, Page, ...etc).
        #
        # @return [ String ] The message
        #
        def resource_message(resource)
          op_label = resource.persisted? ? 'updating': 'creating'
          "    #{op_label} #{truncate(resource.to_s)}"
        end

        # Log a message to the console or the logger depending on the options
        # of the runner. Info is the log level if case the logger has been chosen.
        #
        # @param [ String ] message The message to log.
        #
        def log(message)
          # puts "buffer ? #{@@buffer_enabled.inspect}"
          if @@buffer_enabled
            @@buffer_log << message
          else
            if self.runner.parameters[:console]
              print message
            else
              Mounter.logger.info message #.gsub(/\n$/, '')
            end
          end
        end

        # Put in a buffer the logs generated when executing the block.
        # It means that they will not output unless the flush_log_buffer
        # method is called.
        #
        # @return [ Object ] Thee value returned by the call of the block
        #
        def buffer_log(&block)
          @@buffer_log = ''
          @@buffer_enabled = true
          if block_given?
            block.call.tap { @@buffer_enabled = false }
          end
        end

        # Flush the logs put in a buffer.
        #
        def flush_log_buffer
          @@buffer_enabled = false
          self.log(@@buffer_log)
          @@buffer_log = ''
        end

      end
    end
  end
end