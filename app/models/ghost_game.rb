class GhostGame < ActiveRecord::Base
  establish_connection(:ghost)
  self.table_name = 'games'

  REPLAYS_PATH = File.join(%w{/ cygdrive c Users Jesse gpp replays})

  has_many :users_info, class_name: 'GhostUser', foreign_key: 'gameid', order: 'id ASC'
  has_many :users, class_name: 'GhostMmdUser', foreign_key: 'gameid', order: 'pid ASC'
  has_many :vars, class_name: 'GhostMmdVariable', foreign_key: 'gameid', order: 'pid ASC'

  def map
    self[:map][14..-1]
  end

  def duration
    (self[:duration]/60.0).round
  end

  def replay_path
    possibilities = Dir.glob(File.join([REPLAYS_PATH,'*'])).grep(/#{datetime.strftime("%Y-%m-%d")}/).grep(/#{Regexp.escape(gamename)}/)
    if possibilities.count == 1
      possibilities.first
    else
      nil
    end
  end
end