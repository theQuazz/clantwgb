class GhostMmdUser < ActiveRecord::Base
  establish_connection(:ghost)
  self.table_name = 'w3mmdplayers'

  belongs_to :game, foreign_key: 'gameid', class_name: 'GhostGame'

  def vars
    GhostMmdVariable.where(gameid: gameid, pid: pid)
  end

  def var(name)
    v = vars.where("varname = ?", name.to_s).first
    if v
      v.value_int || v.value_real || v.value_string
    else
      nil
    end
  end

  def get_var(name)
    vars.where("varname = ?", name.to_s).first
  end

  def bugs
    vars.where("varname like ? ", 'bug%').map do |bug|
      bug.value_string
    end
  end

  def kills
    var('kills').to_i
  end

  def deaths
    var('deaths').to_i
  end

  def gold
    var('gold').to_i
  end

  def email
    var('email').to_s
  end

  def troll_class
    var('class').to_s.gsub(/\AUNIT_/,'').gsub('_',' ').downcase
  end
end