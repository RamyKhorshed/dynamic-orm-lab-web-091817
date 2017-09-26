
require 'pry'
require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  ## Table Name
  def self.table_name
    table_name = self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute (sql)
    column_names = []
    table_info.each do |column_data|
      column_names << column_data["name"]
    end
    column_names.compact
  end

  ## def initalize
  def initialize( options = {})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  ## Access Table

  ##
  def table_name_for_insert
    x = self.class.table_name
  end

  def col_names_for_insert
    x = self.class.column_names.delete_if{|name|name== "id"}.join(', ')
  end

  def values_for_insert
    values =[]
    self.class.column_names.each do |col_name|
       values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    ## Insert into table name function, column names function values function (for multiple values you must add parentheses)
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    ## add to instance variable an ID that comes from the database
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql,name)
  end

  def self.find_by(attribute_hash)
    binding.pry
    value = attribute_hash.values.first
    binding.pry
    formatted_value = value.class == Fixnum ? value : "'#{value}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
    DB[:conn].execute(sql)
  end

end
