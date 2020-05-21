require 'httparty'
require 'json'
require 'require_all'
require 'sinatra'

require_all 'lib'
set :port, 8080
set :bind, '0.0.0.0'

get '/' do

end
get '/projects' do
  content_type :json
  projects = Dir.chdir('projects') do Dir.glob('*').select { | f | File.directory? f } end
  projects.to_json
end

get '/projects/:project' do
  content_type :json
  stories = Dir.chdir("projects/#{params[:project]}") do Dir.glob('*').select { | f | File.file? f} end
  stories.to_json
end

get '/projects/:project/:story' do
  content_type :json
  story = JSON.parse (File.read("projects/#{params[:project]}/#{params[:story]}.json"))
  story.to_json
end

post '/stories/:key' do
  request.body.rewind
  credentials = JSON.parse request.body.read
  Dir.mkdir('projects') unless File.exists?('projects')
  Dir.mkdir("projects/#{params[:key].sub(/-.*$/,'')}") unless File.exists?("projects/#{params[:key].sub(/-.*$/,'')}")
  File.write("projects/#{params[:key].sub(/-.*$/,'')}/#{params[:key]}.json", ProcessStory.new(params[:key], credentials).to_golden_story)
end