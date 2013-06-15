Icosmith::Application.routes.draw do

  post "/generate_font" => "font_generator#create"
  root to: 'home#index'

end
