require_dependency "bespoke/application_controller"

module Bespoke
	class ImagesController < ApplicationController
		after_action :verify_authorized

		def create
			@image = Image.new(post_id: image_params[:post_id])

			begin
				authorize @image

				@image.image = image_params[:image]

				respond_to do |format|
					if @image.save
						format.json { render json: @image.image.url }
					else
						format.json { render json: @image.errors.full_messages, status: :unprocessable_entity }
					end
				end
			rescue Pundit::NotAuthorizedError
				respond_to do |format|
					format.json { render json: true, status: :unauthorized }
				end
			end
		end

		def cache
			@image = Image.new

			begin
				authorize @image

				@image.image = file_params[:file]

				respond_to do |format|
					format.json { render json: @image.image.url }
				end
			rescue Pundit::NotAuthorizedError
				respond_to do |format|
					format.json { render json: true, status: :unauthorized }
				end
			end
		end

		def discard
			url = file_params[:file]
			image_id = nil

			# Is this a cached image?
			if (url.include? Bespoke::ImageUploader.cache_dir)
				# If so, retrieve it from the cache
				@image = Image.new
				@image.image.retrieve_from_cache!(cache_name_from_url(url))
			else
				# If not, retrieve it from the database
				image_id, image_name = image_id_and_name_from_url(url)
				@image = Image.find(image_id)
			end

			begin
				authorize @image

				if @image.new_record?
					@image.image.remove!
#				else
#					@image.destroy
				end

				respond_to do |format|
					format.json { render json: {id: image_id}, status: :ok }
				end
			rescue Pundit::NotAuthorizedError
				respond_to do |format|
					format.json { render json: true, status: :unauthorized }
				end
			end
		end

		def destroy
			@image = Image.find(params[:id])

			begin
				authorize @image

				respond_to do |format|
					@image.destroy
					format.json { render json: true, status: :ok }
				end
			rescue Pundit::NotAuthorizedError
				respond_to do |format|
					format.json { render json: true, status: :unauthorized }
				end
			end
		end

		private

		# Only allow a trusted parameter "white list" through.
		def image_params
			params.require(:image).permit(:post_id,
			                              :image)
		end

		def file_params
			params.permit(:file)
		end
	end
end
