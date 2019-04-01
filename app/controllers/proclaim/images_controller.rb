#require_dependency "proclaim/application_controller"

module Proclaim
	class ImagesController < ApplicationController
		after_action :verify_authorized

		def create
			@image = Image.new(post_id: image_params[:post_id])

			handleJsonRequest(@image,
			                  operation: lambda {@image.save},
			                  success_json: lambda {@image.image.url}) do
				@image.image = image_params[:image]
			end
		end

		def cache
			@image = Image.new

			handleJsonRequest(@image, success_json: lambda {@image.image.url}) do
				@image.image = file_params[:file]
			end
		end

		def discard
			url = file_params[:file]
			image_id = nil

			# Is this a cached image?
			if (url.include? Proclaim::ImageUploader.cache_dir)
				# If so, retrieve it from the cache
				@image = Image.new
				@image.image.retrieve_from_cache!(cache_name_from_url(url))
			else
				# If not, retrieve it from the database
				image_id, image_name = image_id_and_name_from_url(url)
				@image = Image.find(image_id)
			end

			handleJsonRequest(@image, success_json: {id: image_id}) do
				if @image.new_record?
					@image.image.remove!
				end
			end
		end

		def destroy
			@image = Image.find(params[:id])

			handleJsonRequest(@image) do
				@image.destroy
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
