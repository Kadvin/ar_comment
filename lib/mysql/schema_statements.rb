module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module SchemaStatements
      # add_column/change_column时支持Column的comment和after属性
      def add_column_options!(sql, options) #:nodoc:
        sql << " DEFAULT #{quote(options[:default], options[:column])}" if options_include_default?(options)
        sql << " NOT NULL" if options[:null] == false
        sql << " COMMENT '#{options[:comment]}' " if options[:comment]
        sql << " AFTER `#{options[:after]}` " if options[:after]
      end

      # 这个可能还没有用起来，要验证下
      # 或者它就是单独使用的
      def change_column_comment(table_name, column_name, type, options = {})
        change_column_sql = "ALTER TABLE #{table_name} CHANGE #{column_name} #{column_name} #{type_to_sql(type, options[:limit], options[:precision], options[:scale])}"
        add_column_options!(change_column_sql, options)
        execute(change_column_sql)
      end

      # 创建Table的时候支持Comment语句
      def create_table(table_name, options = {})
        table_definition = TableDefinition.new(self)
        table_definition.primary_key(options[:primary_key] || Base.get_primary_key(table_name)) unless options[:id] == false

        yield table_definition

        if options[:force] && table_exists?(table_name)
          drop_table(table_name, options)
        end

        create_sql = "CREATE#{' TEMPORARY' if options[:temporary]} TABLE "
        create_sql << "#{quote_table_name(table_name)} ("
        create_sql << table_definition.to_sql
        create_sql << ") #{options[:options]}"
        create_sql << " comment = '#{options[:comment]}'" if options[:comment]
        execute create_sql
      end
    end
  end
end
