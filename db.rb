require "sqlite3"
class WeatherBase
  def initialize(db_name)
    @db = SQLite3::Database.new(db_name)
    @db.execute <<-SQL
CREATE TABLE IF NOT EXISTS history ( 
  request TEXT NOT NULL,
  answer TEXT NOT NULL,
  user_id INTEGER NOT NULL
);
SQL
  end

  def get_history(id, limit = 20)
    history = ""
    sql = "SELECT request, answer FROM history WHERE user_id == #{id} ORDER BY rowid DESC"
    if limit.to_i.integer? and limit.to_i > 0
      sql += " LIMIT #{limit}"
    end
    @db.execute(sql) do |row|
      history += "#{row[0]}\n\t#{row[1]}\n"
    end
    if history.empty?
      history = "History empty"
    end
    history
  end
  
  def record(request, answer, user_id)
    @db.execute("INSERT INTO history VALUES( ?, ?, ?)", [request, answer, user_id])
  end
end