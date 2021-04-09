class Api::CantusFirmusScoresController < ApplicationController
  def create
    cantus_firmus = CantusFirmusScore.new
    cantus_firmus.startup
    cantus_firmus.length = params[:length].to_i
    @notes = cantus_firmus.build_cantus_firmus
    @iterations = cantus_firmus.iterations
    render "show.json.jb"
  end

  def rapidfire
    12.times do
      cantus_firmus = CantusFirmusScore.new
      cantus_firmus.startup
      cantus_firmus.length = rand(8..16)
      cantus_firmus.build_cantus_firmus
    end
    render json: { message: "good job (thumbs up)"}
  end
end
