module Locomotive
  module Mounter
    module Reader
      module FileSystem

        class Collection

          def initialize(reader)
            @items = Hash.new { |hash, key| hash[key] = reader.fetch_one(key) }
            @reader = reader
          end

          def all
            @reader.all_slugs.each { |slug| @items[slug] }
            @items
          end

          def where
            raise 'TODO'
          end

          def size
            all.size
          end

          def each
            yield all.values.each.next
          end

          def [](slug)
            @items[slug]
          end
        end
      end
    end
  end
end
