class Api::ErrorsController < ApplicationController
  def create
    render "error.json.jb"
  end
end
