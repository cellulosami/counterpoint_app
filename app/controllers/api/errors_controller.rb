class Api::ErrorsController < ApplicationController
  def create
    @error = CantusFirmusError.new
    @notes = params[:notes] || "no notes here"
    @error.evaluate(@notes)
    render "error.json.jb"
  end
end
