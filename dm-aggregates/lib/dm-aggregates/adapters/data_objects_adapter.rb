module DataMapper
  module Adapters
    class DataObjectsAdapter
      def aggregate(query)
        with_reader(read_statement(query), query.bind_values) do |reader|
          results = []

          while(reader.next!) do
            row = query.fields.zip(reader.values).map do |field,value|
              if field.respond_to?(:operator)
                send(field.operator, field.target, value)
              else
                field.typecast(value)
              end
            end

            results << (query.fields.size > 1 ? row : row[0])
          end

          results
        end
      end

      private

      def count(property, value)
        value.to_i
      end

      def min(property, value)
        property.typecast(value)
      end

      def max(property, value)
        property.typecast(value)
      end

      def avg(property, value)
        property.type == Integer ? value.to_f : property.typecast(value)
      end

      def sum(property, value)
        property.typecast(value)
      end

      module SQL
        private

        alias original_property_to_column_name property_to_column_name

        def fields_statement(query)
          qualify = query.links.any?
          query.fields.map { |p| property_to_column_name(query.repository, p, qualify, query.unique?) } * ', '
        end
        
        def property_to_column_name(repository, property, qualify, unique=false)
          case property
            when Query::Operator
              aggregate_field_statement(repository, property.operator, property.target, qualify, unique)
            when Property
              original_property_to_column_name(repository, property, qualify)
            else
              raise ArgumentError, "+property+ must be a DataMapper::Query::Operator or a DataMapper::Property, but was a #{property.class} (#{property.inspect})"
          end
        end

        def aggregate_field_statement(repository, aggregate_function, property, qualify, unique=false)
          column_name = if aggregate_function == :count && property == :all
            '*'
          else
            unique ? "distinct #{property_to_column_name(repository, property, qualify)}" :
              property_to_column_name(repository, property, qualify)
          end

          function_name = case aggregate_function
            when :count then 'COUNT'
            when :min   then 'MIN'
            when :max   then 'MAX'
            when :avg   then 'AVG'
            when :sum   then 'SUM'
            else raise "Invalid aggregate function: #{aggregate_function.inspect}"
          end

          "#{function_name}(#{column_name})"
        end
      end # module SQL

      include SQL
    end # class DataObjectsAdapter
  end # module Adapters
end # module DataMapper
