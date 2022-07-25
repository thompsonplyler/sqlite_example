require_relative "../config/environment.rb"
require 'active_support/inflector'

class Savable

  @@all = {}

  def self.create(attributes = {})
    self.new(attributes).save
  end 

  def self.all
    @@all[self] ||= DOGS_DB.execute("SELECT * FROM #{self.table_name}").map do |row|
      self.new_from_row(row)
    end
  end

  def self.new_from_row(row)
    self.new(row.transform_keys(&:to_sym))
  end

  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.column_names

    sql = "pragma table_info('#{table_name}')"

    table_info = DOGS_DB.execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def initialize(options={})
    options.each do |property, value|
      if self.respond_to?("#{property.to_s}=") 
        self.send("#{property.to_s}=", value) 
      end 
    end
  end

  def save
    if self.id
      self.update
    else 
      # sql = <<-SQL 
      # SQL
      DOGS_DB.execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})") 
      @id = DOGS_DB.execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
      self
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DOGS_DB.execute(sql)
  end

  def self.find_by(attribute_hash)
    value = attribute_hash.values.first
    formatted_value = value.class == Fixnum ? value : "'#{value}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
    DOGS_DB.execute(sql)
  end
end