Rails.application.routes.draw do
  root 'welcome#index'

  get '/auth/:provider/callback' => 'sessions#create'

  get '/withings/subscribe' => 'withings_notification#subscribe'
  get '/withings/callback' => 'withings_notification#callback'
end
