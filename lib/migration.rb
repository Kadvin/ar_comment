require "active_record/base"
require "active_record/migration"
module ActiveRecord
  class Migration
    class << self
      def oracle?
        config = ActiveRecord::Base.configurations[Rails.env].with_indifferent_access
        config['adapter'] == "oracle_enhanced"
        # defined?(ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter)
      end

      def mysql?
        config = ActiveRecord::Base.configurations[Rails.env].with_indifferent_access
        config['adapter'] == "mysql"
        # defined?(ActiveRecord::ConnectionAdapters::MysqlAdapter)
      end
    end
  end
end
