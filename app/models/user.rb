class User < ActiveRecord::Base

  after_initialize :init_stats

  def name=(new_name)
    super
    init_stats
  end

  def self.top_query(opt={})
    opt = {start:0, num:10, order_var:'games', order_sort:'desc'}.merge opt
    %Q{
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
      INNER JOIN w3mmdvars wvk ON wp.gameid = wvk.gameid AND wp.pid = wvk.pid AND wvk.varname = 'kills'
      INNER JOIN w3mmdvars wvd ON wp.gameid = wvd.gameid AND wp.pid = wvd.pid AND wvd.varname = 'deaths'
      INNER JOIN w3mmdvars wvg ON wp.gameid = wvg.gameid AND wp.pid = wvg.pid AND wvg.varname = 'gold'
      GROUP BY wp.name
      ORDER BY #{opt[:order_var]} #{opt[:order_sort]}
      LIMIT #{opt[:start]}, #{opt[:num]}
    }
  end

  def self.top(opt={})
    users = []
    Ghost.connection.select_all(top_query(opt)).each do |row|
      user = User.new
      row.each do |key,var|
        attr_accessor key.to_sym
        user.send("#{key}=".to_sym, var)
      end
      users << user
    end
    users
  end

  def query
    %Q{
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
      INNER JOIN w3mmdvars wvk ON wp.gameid = wvk.gameid AND wp.pid = wvk.pid AND wvk.varname = 'kills'
      INNER JOIN w3mmdvars wvd ON wp.gameid = wvd.gameid AND wp.pid = wvd.pid AND wvd.varname = 'deaths'
      INNER JOIN w3mmdvars wvg ON wp.gameid = wvg.gameid AND wp.pid = wvg.pid AND wvg.varname = 'gold'
      WHERE wp.name = '#{nickname}'
      GROUP BY wp.name
      LIMIT 1
    }
  end

  def init_stats
    Ghost.connection.select_all(query).first.each do |key,var|
      instance_variable_set "@#{key}", var
      self[key.to_sym] = var
      self.define_singleton_method key.to_sym do self[key.to_sym] end unless respond_to? key.to_sym
    end if nickname
  end
end