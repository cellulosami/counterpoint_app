class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, if: -> { request.format.html? }
end
