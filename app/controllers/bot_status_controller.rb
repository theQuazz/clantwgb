class BotStatusController < ApplicationController

  KEY = 'C14n7wG8'

  def update_game_info
    raise "no gameinfo param" unless params[:gameinfo]

    game_string = params[:getgames]
    game_info = game_string.scan(/(.*)(\(\d+\/\d+\))/).flatten

    raise "bad game hash" unless params[:gamehash] == Digest::SHA1.hexdigest("#{KEY}#{game_string}")

    @@game = {
      datetime: Time.now.to_s,
      gamename: (game_info.any? ? game_info[0] : game_string),
      slotsfull: game_info[1]
    }

    Rails.logger.debug @@game

    if params[:gameinfo] == "noreturn"
      render text: ""
    else
      render json: @@game
    end
  end

  def get_game_info
    render json: (@@game ||= {datetime: (Time.now - 1.year), gamename: "", slotsfull: ""})
  end
end