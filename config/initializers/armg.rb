require "active_support/lazy_load_hooks"
require "rgeo"
require "armg"

ActiveSupport.on_load(:active_record) do
  module Armg
    class CustomSerializer
      def initialize
        factory = ::RGeo::Cartesian.simple_factory(srid: 4612, uses_lenient_assertions: true)
        @base = ::Armg::WkbSerializer.new(factory:)
        @wkt_parser = ::RGeo::WKRep::WKTParser.new(factory, default_srid: 4612)
      end

      def serialize(value)
        value = @wkt_parser.parse(value) if value.is_a?(String)
        @base.serialize(value)
      end
    end

    class CustomDeserializer
      def initialize
        factory = ::RGeo::Cartesian.simple_factory(srid: 4612, uses_lenient_assertions: true)
        @base = ::Armg::WkbDeserializer.new(factory:)
      end

      def deserialize(mysql_geometry)
        @base.deserialize(mysql_geometry)
      end
    end
  end

  Armg.serializer = Armg::CustomSerializer.new
  Armg.deserializer = Armg::CustomDeserializer.new
end
