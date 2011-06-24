require 'rubygems'
require 'mysql'

Mysql.new('localhost', '', '', 'information_schema') do |con|
  puts "Connected to the information_schema schema"
  schemas = {}
  con.query("SELECT table_name, engine, table_schema FROM information_schema.tables WHERE table_schema NOT LIKE 'mysql' AND table_schema NOT LIKE 'information_schema' AND engine LIKE 'MyISAM'").inject(schemas) do |schemas, row|
    schemas[row[2]] = [] unless schemas[row[2]].is_a? Array
    schemas[row[2]].push(row[0])
  end
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
end
