class GhostUser < ActiveRecord::Base
  establish_connection(:ghost)
  self.table_name = 'gameplayers'

  delegate :kills, :deaths, :gold, :bugs, :email, :troll_class, to: :mmd

  belongs_to :game, class_name: "GhostGame", foreign_key: 'gameid'

  def mmd
    GhostMmdUser.where(gameid: gameid, name: name).first
  end
end