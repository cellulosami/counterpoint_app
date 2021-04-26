class Api::ErrorsController < ApplicationController
  def create
    @notes = params[:notes] || "no notes here"
    @error = CantusFirmusError.new
    @error.mode = params[:mode] || "no mode found"
    @error.evaluate(@notes)
    render "error.json.jb"
  end
end
