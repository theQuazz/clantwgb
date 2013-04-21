class User < ActiveRecord::Base

  after_initialize :init_stats

  ORDER_VARS = %w{
    games
    wins
    losses
    kills
    deaths
    gold
    max_kills
    max_deaths
    max_gold
  }

  ORDER_SORT = %w{
    ASC
    DESC
  }

  MULTIPLE_PLAYERS = %Q{
    SELECT
    wp.name AS 'name',
    CAST( SUM( CASE WHEN wp.flag != ''      THEN 1 ELSE 0 END ) AS SIGNED ) AS 'games',
    CAST( SUM( CASE WHEN wp.flag = 'winner' THEN 1 ELSE 0 END ) AS SIGNED ) AS 'wins',
    CAST( SUM( CASE WHEN wp.flag = 'loser'  THEN 1 ELSE 0 END ) AS SIGNED ) AS 'losses',
    CAST( SUM( wvk.value_int ) AS SIGNED ) AS 'kills',
    CAST( SUM( wvd.value_int ) AS SIGNED ) AS 'deaths',
    CAST( SUM( wvg.value_int ) AS SIGNED ) AS 'gold',
    CAST( MAX( wvk.value_int ) AS SIGNED ) AS 'max_kills',
    CAST( MAX( wvd.value_int ) AS SIGNED ) AS 'max_deaths',
    CAST( MAX( wvg.value_int ) AS SIGNED ) AS 'max_gold'
    FROM w3mmdplayers wp
    LEFT OUTER JOIN w3mmdvars wvk ON wp.gameid = wvk.gameid AND wp.pid = wvk.pid AND wvk.varname = 'kills'
    LEFT OUTER JOIN w3mmdvars wvd ON wp.gameid = wvd.gameid AND wp.pid = wvd.pid AND wvd.varname = 'deaths'
    LEFT OUTER JOIN w3mmdvars wvg ON wp.gameid = wvg.gameid AND wp.pid = wvg.pid AND wvg.varname = 'gold'
    GROUP BY wp.name
  }

  SINGLE_PLAYER = %Q{
    SELECT
    CAST( SUM( CASE WHEN wp.flag != ''      THEN 1 ELSE 0 END ) AS SIGNED ) AS 'games',
    CAST( SUM( CASE WHEN wp.flag = 'winner' THEN 1 ELSE 0 END ) AS SIGNED ) AS 'wins',
    CAST( SUM( CASE WHEN wp.flag = 'loser'  THEN 1 ELSE 0 END ) AS SIGNED ) AS 'losses',
    CAST( SUM( wvk.value_int ) AS SIGNED ) AS 'kills',
    CAST( SUM( wvd.value_int ) AS SIGNED ) AS 'deaths',
    CAST( SUM( wvg.value_int ) AS SIGNED ) AS 'gold',
    CAST( MAX( wvk.value_int ) AS SIGNED ) AS 'max_kills',
    CAST( MAX( wvd.value_int ) AS SIGNED ) AS 'max_deaths',
    CAST( MAX( wvg.value_int ) AS SIGNED ) AS 'max_gold'
    FROM w3mmdplayers wp
    LEFT OUTER JOIN w3mmdvars wvk ON wp.gameid = wvk.gameid AND wp.pid = wvk.pid AND wvk.varname = 'kills'
    LEFT OUTER JOIN w3mmdvars wvd ON wp.gameid = wvd.gameid AND wp.pid = wvd.pid AND wvd.varname = 'deaths'
    LEFT OUTER JOIN w3mmdvars wvg ON wp.gameid = wvg.gameid AND wp.pid = wvg.pid AND wvg.varname = 'gold'
    WHERE wp.name = ?
    GROUP BY wp.name
    LIMIT 1
  }

  def name=(new_name)
    super
    init_stats
  end

  def self.top(opt={})
    users = []
    opt   = {start:0, num:10, order_var:'games', order_sort:'desc'}.merge opt
    sql   = MULTIPLE_PLAYERS
    if ORDER_VARS.include? opt[:order_var] and ORDER_SORT.include? opt[:order_sort].upcase
      sql += %Q{ ORDER BY #{opt[:order_var]} #{opt[:order_sort]} }
    end
    sql += %Q{ LIMIT #{Integer(opt[:start])}, #{Integer(opt[:num])}}
    Ghost.connection.select_all(sql).each do |row|
      user = User.new
      row.each do |key,var|
        attr_reader key.to_sym unless user.respond_to? key.to_sym
        user.instance_variable_set "@#{key}", (var||0) # 0 is for if the left join returns nil on a column
      end
      users << user
    end
    users
  end

  def init_stats
    if nickname
      sql = ActiveRecord::Base.send(:sanitize_sql_array, [SINGLE_PLAYER, nickname])
      Ghost.connection.select_one(sql).each do |key,var|
        instance_variable_set "@#{key}", (var||0) # 0 is for if the left join returns nil on a column
        class_eval do
          attr_reader key.to_sym
        end
      end
    end
  end
end
