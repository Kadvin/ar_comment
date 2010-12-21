
require "active_record/base"
require "active_record/connection_adapters/mysql_adapter"

#增强MySQL连接获取到的元信息
module ActiveRecord
  class Base
    class << self
      # ==显示对象所对应的数据库表的注释
      # 一般我们将该表的显示名称放在表注释里面
      # 
      # MySqL支持通过以下语法为MySQL表设置表的Comment:
      # CREATE TABLE ... COMMENT '表的说明';
      # 
      # 我们支持通过Migration创建表的时候设定表的Comment
      # create_table :user,... :comment=>"表的说明"
      def comment
        return @comment if @comment
        result = self.connection.select_one("show create table #{table_name}")
        return @comment = $1 if /comment='(\w+)'/im =~ result["Create Table"]
      end
      
      # ==显示对象所对应的数据库表的某列的注释
      # 一般我们将该列的显示名称放在列注释里面
      def column_comment(column_name)
        column = self.columns_hash[column_name.to_s]
        if( column )
          return column.comment
        else
          return column_name.to_s
        end
      end

      def column_by_comment(comment)
        self.columns.find do |col|
          col.label == comment
        end
      end
    end
  end
end
