
module ActiveRecord
  module ConnectionAdapters

    class ColumnDefinition
      attr_accessor :comment
      def to_sql
        column_sql = "#{base.quote_column_name(name)} #{sql_type}"
        column_options = {}
        column_options[:null] = null unless null.nil?
        column_options[:default] = default unless default.nil?
        # Added new line
        column_options[:comment] = comment if comment
        add_column_options!(column_sql, column_options) unless type.to_sym == :primary_key
        column_sql
      end
      alias to_s :to_sql
    end

    class TableDefinition
      def column(name, type, options = {})
        column = self[name] || ColumnDefinition.new(@base, name, type)
        column = self[name] || ColumnDefinition.new(@base, name, type)
        if options[:limit]
          column.limit = options[:limit]
        elsif native[type.to_sym].is_a?(Hash)
          column.limit = native[type.to_sym][:limit]
        end
        column.precision = options[:precision]
        column.scale = options[:scale]
        column.default = options[:default]
        column.null = options[:null]
        # Added new line
        column.comment = options[:comment] if options[:comment]
        @columns << column unless @columns.include? column
        self
      end

    end

  end
end
