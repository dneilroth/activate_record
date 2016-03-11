require_relative 'db_connection'
require_relative '01_sql_object'

module Lockable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def is_lockable?
      self.columns.map { |column| "#{column}"}.include?("lock_version")
    end
  end

  def is_locked?
    if self.class.is_lockable?
      results =  DBConnection.execute(<<-SQL, self.id)
        SELECT
          *
        FROM
          #{self.class.table_name}
        WHERE
          id = ?
        LIMIT
          1
        SQL

      self.lock_version != self.class.parse_all(results).first.lock_version
    else
      return false
    end
  end

  def update
    raise "ActivateRecord::StaleObject" if self.is_locked?
    super
  end

end

class SQLObject
  prepend Lockable
  include Lockable
end
