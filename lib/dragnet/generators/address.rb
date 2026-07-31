# frozen_string_literal: true

module Dragnet
  module Generators
    class Address < Dragnet::ParameterizedGenerator
      attr_reader :street, :city, :state, :zip_code, :latitude, :longitude

      def initialize(street: nil, city: nil, state: nil, zip_code: nil, latitude: nil, longitude: nil)
        super()

        @street    = street.generate    || Faker::Address.street_address
        @city      = city.generate      || Faker::Address.city
        @state     = state.generate     || Faker::Address.state_abbr
        @zip_code  = zip_code.generate  || Faker::Address.zip_code
        @latitude  = latitude.generate  || Faker::Address.latitude
        @longitude = longitude.generate || Faker::Address.longitude
      end

      def to_s(long: false)
        buffer = +""
        buffer << "#{street}#{long ? "\n" : ", "}" if street
        buffer << "#{city}, #{state}" if city && state
        buffer << " #{zip_code}" if zip_code
        buffer.freeze
      end
      alias inspect to_s

      def to_h
        {
          'coordinates' => [latitude, longitude],
          'address'     => street,
          'city'        => city,
          'state_code'  => state,
          'zip_code'    => zip_code,
        }.freeze
      end

      def to_a
        [to_h]
      end

      def call
        string = to_s
        Geocoder::Lookup::Test.add_stub(string, to_a)
        string
      end
    end
  end
end
