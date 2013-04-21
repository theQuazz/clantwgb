class GamesController < ApplicationController
  def index
    @games = GhostGame.where("gamename LIKE ?", "%TwGB%").order("datetime desc").limit(25)
    @no_side_bar = true
  end
  def show
    @game  = GhostGame.find(params[:id], include: [:users])
  end
  def download_replay
    @game = GhostGame.find(params[:id])
    send_file @game.replay_path
  end
end