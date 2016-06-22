require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song


  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.all
    sql = <<-SQL
      SELECT * FROM #{self.table_name};
    SQL

    rows = self.db.execute(sql)
    rows.map do |row|
      self.new

    end
  ##NOT DONE YET
  end


  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT NOT EXISTS #{table_name}(
        ATTRIBUTES.map do |k,v|
          "#{k} #{v}"
        end.join(",")
      end)
    SQL

  end


  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)



    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
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
    DB[:conn].execute(sql)
  end

end


PRIVATE
#NOTES FROM 06/22
def initialize(attributes={})
  @id = attributes.delete[:id] 
  #will first return the ID (only once) and then throw the pair away
  #becaues when you want to iterate through it WITHOUT the id
  #also don't want to change the id - no methods for id so you cant do book.id = '1' 
  #can only set it at initialization
  attributes.each do |attribute, value|
    self.send("#{attribute}=") value
    #you gotta do send("#{}="), can't just do self.attr because that's not a method you can call
    #MUST HAVE THAT = SIGN
    #must use string interpolation because otherwise you will be literally passing through attribute=
    #but you actually want to call title=
  end

end


