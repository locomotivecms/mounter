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