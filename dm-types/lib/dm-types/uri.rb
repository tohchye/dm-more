require 'rubygems'
require 'addressable/uri'

module DataMapper
  module Types
    class URI < DataMapper::Type
      primitive String

      def self.load(value, property)
        Addressable::URI.parse(value)
      end

      def self.dump(value, property)
        return nil if value.nil?
        value.to_s
      end

      def self.typecast(value, property)
        value.kind_of?(Addressable::URI) ? value : load(value.to_s, property)
      end
    end # class URI
  end # module Types
end # module DataMapper
