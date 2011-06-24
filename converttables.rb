require 'rubygems'
require 'mysql'

begin
  con = Mysql.new('localhost', '', '', 'information_schema')
  puts "Connected to the information_schema schema"
  schemas = Hash.new()
  tables = con.query("SELECT table_name, engine, table_schema FROM information_schema.tables WHERE table_schema NOT LIKE 'mysql' AND table_schema NOT LIKE 'information_schema' AND engine LIKE 'MyISAM'")
  puts "Number of rows returned: #{tables.num_rows}"
  tables.each do |row|
    if !schemas[row[2]] then
      schemas[row[2]] = Array.new()
    end
    schemas[row[2]].push(row[0])
  end
  tables.free
  schemas.keys.each do |schema|
    puts "Processing schema: #{schema}"
    con_schema = Mysql.new('localhost', '', '', schema)
    schemas[schema].each do |table|
      puts "Processing table: #{table}"
      begin
        con_schema.query("ALTER TABLE #{table} ENGINE=InnoDB")
      rescue Mysql::Error => e
        puts "Error code: #{e.errno}"
        puts "Error message: #{e.error}"
        puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
      end
    end
    con_schema.close
  end
rescue Mysql::Error => e
  puts "Error code: #{e.errno}"
  puts "Error message: #{e.error}"
  puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
ensure
  con.close if con
end
