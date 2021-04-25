class Api::CantusFirmusScoresController < ApplicationController
  def create
    cantus_firmus = CantusFirmusScore.new
    cantus_firmus.length = params[:length].to_i
    cantus_firmus.mode = params[:mode]
    cantus_firmus.startup
    @notes = cantus_firmus.build_cantus_firmus
    @iterations = cantus_firmus.iterations
    @mode = cantus_firmus.mode
    render "show.json.jb"
  end

  def rapidfire
    scores = []
    params[:repetitions].to_i.times do
      cantus_firmus = CantusFirmusScore.new
      cantus_firmus.startup
      cantus_firmus.length = params[:length].to_i
      scores << cantus_firmus.build_cantus_firmus
    end
    render json: scores
  end
end
