require 'stringio'
require 'bigdecimal'

module ActiveRecord
  # This class is used to dump the database schema for some connection to some
  # output format (i.e., ActiveRecord::Schema).
  class SchemaDumper #:nodoc:

    private

      def table(table, stream)
        columns = @connection.columns(table)
        begin
          tbl = StringIO.new

          if @connection.respond_to?(:pk_and_sequence_for)
            pk, pk_seq = @connection.pk_and_sequence_for(table)
          end
          pk ||= 'id'

          tbl.print "  create_table #{table.inspect}"
          if columns.detect { |c| c.name == pk }
            if pk != 'id'
              tbl.print %Q(, :primary_key => "#{pk}")
            end
          else
            tbl.print ", :id => false"
          end
          tbl.print ", :force => true"
          statement = @connection.select_one("show create table #{table}")
          comment = $1 if /comment='(\w+)'/im =~ statement["Create Table"]
          tbl.print ", :comment => '#{comment}'" if comment
          tbl.puts " do |t|"

          column_specs = columns.map do |column|
            raise StandardError, "Unknown type '#{column.sql_type}' for column '#{column.name}'" if @types[column.type].nil?
            next if column.name == pk
            spec = {}
            spec[:name]      = column.name.inspect
            spec[:type]      = column.type.to_s
            spec[:limit]     = column.limit.inspect if column.limit != @types[column.type][:limit] && column.type != :decimal
            spec[:precision] = column.precision.inspect if !column.precision.nil?
            spec[:scale]     = column.scale.inspect if !column.scale.nil?
            spec[:null]      = 'false' if !column.null
            spec[:default]   = default_string(column.default) if !column.default.nil?
            spec[:comment]   = column.comment.inspect
            (spec.keys - [:name, :type]).each{ |k| spec[k].insert(0, "#{k.inspect} => ")}
            spec
          end.compact

          # find all migration keys used in this table
          keys = [:name, :limit, :precision, :scale, :default, :null, :comment] & column_specs.map(&:keys).flatten

          # figure out the lengths for each column based on above keys
          lengths = keys.map{ |key| column_specs.map{ |spec| spec[key] ? spec[key].length + 2 : 0 }.max }

          # the string we're going to sprintf our values against, with standardized column widths
          format_string = lengths.map{ |len| "%-#{len}s" }

          # find the max length for the 'type' column, which is special
          type_length = column_specs.map{ |column| column[:type].length }.max

          # add column type definition to our format string
          format_string.unshift "    t.%-#{type_length}s "

          format_string *= ''

          column_specs.each do |colspec|
            values = keys.zip(lengths).map{ |key, len| colspec.key?(key) ? colspec[key] + ", " : " " * len }
            values.unshift colspec[:type]
            tbl.print((format_string % values).gsub(/,\s*$/, ''))
            tbl.puts
          end

          tbl.puts "  end"
          tbl.puts

          indexes(table, tbl)

          tbl.rewind
          stream.print tbl.read
        rescue => e
          stream.puts "# Could not dump table #{table.inspect} because of following #{e.class}"
          stream.puts "#   #{e.message}"
          stream.puts
        end

        stream
      end
  end
end
