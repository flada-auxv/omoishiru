Rails.application.routes.draw do
  root 'welcome#index'

  get '/auth/:provider/callback' => 'sessions#create'

  get '/withings/subscribe' => 'withings_notification#subscribe'
  match '/api/withings/callback' => 'api/withings#callback', via: %i(get post)
end
