module Mongify
  module Mongoid
    class Model
      #
      # Field for a Mongoid file
      #
      class Field
        ACCEPTED_TYPES = [
          "Array",
          "BigDecimal",
          "Boolean",
          "Date",
          "DateTime",
          "Float",
          "Hash",
          "Integer",
          "Moped::BSON::ObjectId",
          "Moped::BSON::Binary",
          "Range",
          "Regexp",
          "String",
          "Symbol",
          "Time",
          "TimeWithZone"
        ]

        TRANSLATION_TYPES = {
          array: "Array",
          bigdecimal: "BigDecimal",
          boolean: "Boolean",
          date: "Date",
          datetime: "DateTime",
          float: "Float",
          hash: "Hash",
          integer: "Integer",
          objectid: "Moped::BSON::ObjectId",
          binary: "Moped::BSON::Binary",
          range: "Range",
          regexp: "Regexp",
          string: "String",
          symbol: "Symbol",
          time: "Time",
          text: "String",
          timewithzone: "TimeWithZone"
        }

        attr_accessor :name, :type, :options
        def initialize(name, type, options={})
          type = translate_type(type)
          check_field_type(type)
          @name = name
          @type = type
          @options = options
        end

        #######
        private
        #######
        
        # Tries to find a translation for a SQL type to a Mongoid Type
        def translate_type(name)
          TRANSLATION_TYPES[name.to_s.downcase.to_sym] || name
        end
        
        # Raises InvalidField if field type is unknown
        def check_field_type (name)
          raise InvalidField, "Unknown field type #{name}" unless ACCEPTED_TYPES.map(&:downcase).include? name.to_s.downcase
        end
      end
    end
  end
end