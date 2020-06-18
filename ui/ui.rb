require 'sinatra'

set :port, 8081
set :bind, '0.0.0.0'


get '/' do
  erb :index
end

get '/:project' do
  erb :project, :locals => {:project => params[:project]}
end

get '/:project/:key' do
  erb :story, :locals => {:project => params[:project], :story => params[:key]}
end

get '/:project/test_results/:key' do
  erb :test_results, :locals => {:project => params[:project], :story => params[:key]}
end