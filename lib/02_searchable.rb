require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.map { |key, v| "#{key} = ?"}.join(" AND ")
  results =  DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL
    self.parse_all(results)
  end

  def find
    super
    return nil if obj.nil?

    if obj.class.is_lockable?
      @lock_version = obj.lock_version
    end

    obj
  end
end

class SQLObject
  extend Searchable
end
