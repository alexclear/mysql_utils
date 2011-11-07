require 'rubygems'
require 'mysql'

begin
  status = 1
  while status == 1
    con = Mysql.new('localhost', 'root', '', 'information_schema')
    puts "Connected to the information_schema schema"
    con.query("SHOW SLAVE STATUS").each do |row|
      puts "#{row[37]}"
      if row[37].match(/^Error/) || row[37].match(/^Query caused different errors/)
        puts "Skipping..."
        con.query("SET GLOBAL sql_slave_skip_counter = 1")
        con.query("START SLAVE")
        sleep(1)
      else
        status = 0
      end
    end
  end
rescue Mysql::Error => e
  puts "Error code: #{e.errno}"
  puts "Error message: #{e.error}"
  puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
ensure
  con.close if con
end
