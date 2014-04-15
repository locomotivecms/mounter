module Locomotive
  module Mounter
    module Reader
      module FileSystem

        class Collection

          def initialize(reader)
            @items = Hash.new { |hash, key| hash[key] = reader.fetch_one(key) }
            @slugs = reader.all_slugs
          end

          def all
            @slugs.each { |slug| @items[slug] }
            @items
          end

          def where
            raise 'TODO'
          end

          def size
            @slugs.size
          end

          def [](slug)
            @items[slug]
          end
        end
      end
    end
  end
end
