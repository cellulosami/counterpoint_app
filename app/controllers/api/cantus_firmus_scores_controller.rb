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
    10.times do
      cantus_firmus = CantusFirmusScore.new
      cantus_firmus.startup
      cantus_firmus.length = params[:length].to_i
      cantus_firmus.build_cantus_firmus
    end
    render json: { message: "good job (thumbs up)"}
  end
end
