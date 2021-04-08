class Api::CantusFirmusScoresController < ApplicationController
  def create
    cantus_firmus = CantusFirmusScore.new
    @notes = cantus_firmus.build_cantus_firmus
    @iterations = cantus_firmus.iterations
    render "show.json.jb"
  end
end
