# 
# =MySQL DB 接口层Comment支持
#
module ActiveRecord
  module ConnectionAdapters
    # 增强MyqlColumn，支持comment属性
    MysqlColumn.class_eval{
      attr_accessor :comment
    }
    class MysqlAdapter
      def columns(table_name, name = nil)#:nodoc:
        sql = "SHOW FULL FIELDS FROM #{quote_table_name(table_name)}"
        columns = []
        result = execute(sql, :skip_logging)
        result.each { |field|
          column = MysqlColumn.new(field[0], field[5], field[1], field[3] == "YES")
          columns << column
          column.comment = field[8]
        }
        result.free
        columns
      end
    end
  end
end
