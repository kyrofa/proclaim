#require_dependency "proclaim/application_controller"

module Proclaim
	class PostsController < Proclaim::ApplicationController
		before_action :authenticate_author, except: [:index, :show]
		after_action :verify_authorized
		after_action :verify_policy_scoped, only: :index
		before_action :set_post, only: [:show, :edit, :update, :destroy]

		# GET /posts
		def index
			@posts = policy_scope(Post).order(published_at: :desc, updated_at: :desc)
			authorize Post
		end

		# GET /posts/1
		def show
			authorize @post

			# If an old id or a numeric id was used to find the record, then
			# the request path will not match the post_path, and we should do
			# a 301 redirect that uses the current friendly id.
			if request.path != post_path(@post)
				return redirect_to @post, status: :moved_permanently
			end
		end

		# GET /posts/new
		def new
			@post = Post.new(author: current_author)
			authorize @post
		end

		# GET /posts/1/edit
		def edit
			authorize @post
		end

		# POST /posts
		def create
			@post = Post.new(post_params)
			@post.author = current_author

			if params[:publish] == "true"
				@post.publish
			end

			authorize @post

			if @post.save
				redirect_to @post, notice: 'Post was successfully created.'
			else
				render :new
			end
		end

		# PATCH/PUT /posts/1
		def update
			@post.assign_attributes(post_params)

			if (params[:publish] == "true") and not @post.published?
				@post.publish
				@post.author = current_author # Reassign author when it's published
			end

			authorize @post

			if @post.save
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

		def user_not_authorized(exception)
			if exception.policy.is_a? PostPolicy and exception.query == "show?"
				# Don't leak that this resource actually exists. Turn the
				# "permission denied" into a "not found"
				raise ActiveRecord::RecordNotFound
			else
				super()
			end
		end

		# Use callbacks to share common setup or constraints between actions.
		def set_post
			@post = Post.friendly.find(params[:id])
		end

		# Only allow a trusted parameter "white list" through.
		def post_params
			# Ensure post title is sanitized of all HTML
			if params[:post].include? :title
				params[:post][:title] = HTMLEntities.new.decode(Rails::Html::FullSanitizer.new.sanitize(params[:post][:title]))
			end

			params.require(:post).permit(:title, :body, :quill_body)
		end
	end
end
