Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :pokedexes
  resources :skills
  resources :pokemons do
    post 'heal'
    get 'heal_all', on: :collection
  	resources :pokemon_skills
  end
  resources :pokemon_battles do
    resources :pokemon_battle_logs
    get 'auto_battle'
  	post 'attack'
  	post 'surrender'
  end
  root 'pages#home'
end
