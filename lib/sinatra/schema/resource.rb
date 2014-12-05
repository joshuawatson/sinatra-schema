module Sinatra
  module Schema
    class Resource
      attr_accessor :id, :path, :title, :defs, :links, :description, :properties

      def initialize(options)
        @path  = options.fetch(:path).chomp("/")
        @links = []
        @defs  = {}
      end

      def id
        @id ||= ActiveSupport::Inflector.singularize(path.split("/").last).to_sym
      end

      def title
        @title ||= ActiveSupport::Inflector.singularize(path.split("/").last).capitalize
      end

      def validate_response!(res)
        unless res.is_a?(Hash)
          raise "Response should return a hash"
        end

        if properties
          Utils.validate_keys!(properties, res)
        end
      end

      def to_schema
        {
          title: title,
          description: description
        }
      end
    end
  end
end
