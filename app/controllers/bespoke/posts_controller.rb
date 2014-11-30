require_dependency "bespoke/application_controller"

module Bespoke
	class PostsController < ApplicationController
		before_action :authenticate_author, except: [:index, :show]
		after_action :verify_authorized, :except => :index
		after_action :verify_policy_scoped, :only => :index
		before_action :set_post, only: [:show, :edit, :update, :destroy]

		# GET /posts
		def index
			@posts = policy_scope(Post)
			authorize Post
		end

		# GET /posts/1
		def show
			begin
				authorize @post
			rescue Pundit::NotAuthorizedError
				# Don't leak that this resource actually exists. Turn the
				# "permission denied" into a "not found"
				raise ActiveRecord::RecordNotFound
			end
		end

		# GET /posts/new
		def new
			@post = Post.new
			authorize @post
		end

		# GET /posts/1/edit
		def edit
			authorize @post
		end

		# POST /posts
		def create
			params = post_params
			params[:author] = current_author
			@post = Post.new(params)

			authorize @post

			if @post.save
				redirect_to @post, notice: 'Post was successfully created.'
			else
				render :new
			end
		end

		# PATCH/PUT /posts/1
		def update
			authorize @post

			if @post.update(post_params)
				redirect_to @post, notice: 'Post was successfully updated.'
			else
				render :edit
			end
		end

		# DELETE /posts/1
		def destroy
			authorize @post

			@post.destroy
			redirect_to posts_url, notice: 'Post was successfully destroyed.'
		end

		private

		# Use callbacks to share common setup or constraints between actions.
		def set_post
			@post = Post.find(params[:id])
		end

		# Only allow a trusted parameter "white list" through.
		def post_params
			params.require(:post).permit(:title,
			                             :body,
			                             :published,
			                             :publication_date)
		end
	end
end
