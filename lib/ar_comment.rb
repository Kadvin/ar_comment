require File.join(File.dirname(__FILE__), "migration")

if ActiveRecord::Migration.mysql? or ActiveRecord::Migration.oracle?
  ActiveRecord::ConnectionAdapters::TableDefinition.class_eval do
    # 扩展Timestamps，支持中文注释
    def timestamps
      column(:created_at, :datetime, :comment=>"创建时间")
      column(:updated_at, :datetime, :comment=>"更新时间")
    end
  end

  if ActiveRecord::Migration.mysql?
    Dir[File.join(File.dirname(__FILE__), "mysql/*")].each{|file| require file}
  end

  if ActiveRecord::Migration.oracle?
    Dir[File.join(File.dirname(__FILE__), "oracle/*")].each{|file| require file}
  end

  require 'active_model/translation'
  module ActiveModel

    Translation.module_eval do
      def human_attribute_name_with_comment(attribute, options = {})
        options.update(:raise => true, :default => nil) if (ActiveRecord::Base <=> self) == 1
        human_attribute_name_without_comment(attribute, options)
      rescue I18n::MissingTranslationData # when the resource not defined, use the comment
        col = self.columns_hash[attribute.to_s]
        col.comment rescue attribute.to_s.titleize # when the comment not defined, use attribute
      end
      alias_method_chain :human_attribute_name, :comment
    end

    Name.class_eval do
      def human_with_comment(options = {})
        options.update(:raise => true, :default => nil) if (ActiveRecord::Base <=> @klass) == 1
        human_without_comment(options)
      rescue I18n::MissingTranslationData # when the resource not defined, use the comment
        @klass.table_comment rescue self.titleize # when the comment not defined, use myself
      end
      alias_method_chain :human, :comment
    end
  end
end
