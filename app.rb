require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

set :database, {adapter: "sqlite3", database: "habr.db"}

class Post < ActiveRecord::Base
	has_many :comments, dependent: :destroy
	validates :author, presence: true, length: { minimum: 3 }
	validates :content, presence: true
end

class Comment < ActiveRecord::Base
	belongs_to :post
	validates :comment_content, presence: true
end


get '/' do
	@results = Post.order('created_at DESC')
	erb :index			
end

get '/new' do
	@p = Post.new
	erb :new			
end

post '/new' do
	@p = Post.new params[:post]
	if @p.save
		redirect to '/'
	else
		@error = @p.errors.full_messages.first
		erb :new
	end			
end

get '/details/:post_id' do
	@post = Post.find(params[:post_id])

	@comments = @post.comments
  
  	erb :details		
end

post '/details/:post_id' do
  @post = Post.find(params[:post_id])

  @comment = Comment.new(params[:comment])
  @comment.post = @post
  if @comment.save
  	@comments = @post.comments
  	erb :details
  else
  	@error = @comment.errors.full_messages.first
  	@comments = @post.comments
  	erb :details
  end	
end
