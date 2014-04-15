module Locomotive
  module Mounter
    module Reader
      module FileSystem

        class Collection

          def initialize(reader)
            @items = Hash.new { |hash, key| hash[key] = reader.fetch_one(key) }
          end

          def all
            raise 'TODO'
          end

          def where
            raise 'TODO'
          end

          def [](slug)
            @items[slug]
          end
        end

      end
    end
  end
end
