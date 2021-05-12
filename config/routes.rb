Rails.application.routes.draw do
  namespace :api do
    post "/scores" => "cantus_firmus_scores#create"
    post "/scores/rapidfire" => "cantus_firmus_scores#rapidfire"
    post "/errors" => "errors#create"

    #test request to setup heroku
    get "/scores" => "cantus_firmus_scores#index"
  end
end
