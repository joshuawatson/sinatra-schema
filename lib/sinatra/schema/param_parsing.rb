module Sinatra
  module Schema
    module ParamParsing
      def parse_params(properties)
        case request.media_type
        when nil, "application/json"
          parse_json_params
        when "application/x-www-form-urlencoded"
          cast_regular_params(properties)
        else
          raise "Cannot handle media type #{request.media_type}"
        end
      end

      protected

      def parse_json_params
        body = request.body.read
        return {} if body.length == 0 # nothing supplied

        request.body.rewind # leave it ready for other calls
        supplied_params = MultiJson.decode(body)
        unless supplied_params.is_a?(Hash)
          raise "Invalid request, expecting a hash"
        end

        indifferent_params(supplied_params)
      rescue MultiJson::ParseError
        raise "Invalid JSON"
      end

      def cast_regular_params(properties, root=params)
        casted_params = root.inject({}) do |casted, (k, v)|
          definition = properties[k.to_sym]

          # handle nested params
          if definition.is_a?(Hash) || v.is_a?(Hash)
            casted[k] = cast_regular_params(definition, v)
          else
            # if there's no definition just leave the original param,
            # let the validation raise on this later:
            casted[k]  = definition ? definition.cast(v) : v
          end
          casted
        end
        indifferent_params(casted_params)
      end
    end
  end
end