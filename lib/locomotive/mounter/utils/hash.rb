unless Hash.instance_methods.include?(:deep_stringify_keys)
  class Hash

    # Return a new hash with all keys converted to strings.
    # This includes the keys from the root hash and from all
    # nested hashes.
    def deep_stringify_keys
      result = {}
      each do |key, value|
        result[key.to_s] = value.is_a?(Hash) ? value.deep_stringify_keys : value
      end
      result
    end

  end
end

unless Hash.instance_methods.include?(:deep_symbolize_keys)
  class Hash

    # See http://iain.nl/writing-yaml-files
    def deep_symbolize_keys
      {}.tap do |new_hash|
        self.each do |key, value|
          new_hash.merge!(key.to_sym => (value.is_a?(Hash) ? value.deep_symbolize_keys : value))
        end
      end
    end

  end
end