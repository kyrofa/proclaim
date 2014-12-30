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

			if @post.valid?
				# Save and rewrite each image in Carrierwave's cache
				@post.body = saved_and_rewrite_cached_images(@post.body)

				@post.save

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

			if @post.valid?
				# Save and rewrite each image in Carrierwave's cache
				@post.body = saved_and_rewrite_cached_images(@post.body)

				@post.save

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
			# Ensure post title is sanitized of all HTML
			if params[:post].include? :title
				params[:post][:title] = Rails::Html::FullSanitizer.new.sanitize(params[:post][:title])
			end

			params.require(:post).permit(:title,
			                             :body,
			                             images_attributes: [:id, :image, :_destroy])
		end

		def saved_and_rewrite_cached_images(body)
			document = Nokogiri::HTML.fragment(body)
			cache_path = ImageUploader.cache_dir
			document.css("img").each do |image_tag|
				url = image_tag.attributes["src"].value
				if url.include? cache_path
					cache_name = cache_name_from_url(url)
					if cache_name
						image = @post.images.build
						image.image.retrieve_from_cache!(cache_name)
						image.save

						image_tag.attributes["src"].value = image.image.url
					end
				end
			end

			document.inner_html
		end
	end
end
