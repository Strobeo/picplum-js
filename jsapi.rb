require 'coderay'

class JsApiApp < Sinatra::Base

  get "/" do
    erb :test
  end
  
end