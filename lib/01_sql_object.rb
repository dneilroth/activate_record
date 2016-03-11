require_relative 'db_connection'
require 'active_support/inflector'
require '05_lockable'

class SQLObject
  # include Lockable
  def self.columns
    DBConnection.execute2(<<-SQL)
  SELECT
    *
  FROM
  "#{self.table_name}"
    SQL
    .first.map { |column| column.to_sym}
  end

  def self.finalize!
    columns.each do |column|
      define_method "#{column}=" do |value|
        attributes[column] = value
      end

      define_method "#{column}" do
        attributes[column]
      end
    end

  end

  def self.table_name=(table_name)
      @table_name =table_name
  end

  def self.table_name
    if @table_name
      @table_name
    else
      @table_name = "#{self}".tableize
    end
  end

  def self.all
   results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      SQL

      self.parse_all(results)

  end

  def self.parse_all(results)
    results.map do |object|
      self.new(object)
    end
  end

  def self.find(id)
  results =  DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      id = ?
    LIMIT
      1
    SQL

    obj = self.parse_all(results).first
  end

  def initialize(params = {})
    self.class.finalize!
    params.each do |attr_name, value|
      attr_sym = attr_name.to_sym
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_sym)
      self.send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def lock_version
    @lock_version ||= nil
  end

  def attribute_values
    self.class.columns.map { |column| self.send(column)}
  end

  def insert
    columns = self.class.columns.map(&:to_s)
    col_names = columns.join(", ")
    question_marks = Array.new(columns.length) {"?"}.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
      (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    columns = self.class.columns.map { |column| "#{column} = ?"}
    col_names = columns.join(", ")
    new_values = attribute_values
    new_values[-1] = new_values[-1] + 1 if self.class.is_lockable?

    DBConnection.execute(<<-SQL, *new_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_names}
      WHERE
        id = ?
    SQL

  end

  def save
    self.id.nil? ? insert : update
  end

end
