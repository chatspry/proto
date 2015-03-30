module Protocore
  module Builders
    module AlgorithmBuilder

      def build_algorithm(algorithm)
        case algorithm
        when /rsa/i then OpenSSL::PKey::RSA
        when /dsa/i then OpenSSL::PKey::DSA
        else raise NotImplementedError, "creating keys with the #{ algorithm } algorithm is not supported"
        end
      end

    end
  end
end