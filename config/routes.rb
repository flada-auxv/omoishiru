Rails.application.routes.draw do
  root 'welcome#index'

  get '/auth/:provider/callback' => 'sessions#create'

  get '/withings/subscribe' => 'withings_notification#subscribe'
  match '/withings/callback' => 'withings_notification#callback', via: %i(get post)
end
