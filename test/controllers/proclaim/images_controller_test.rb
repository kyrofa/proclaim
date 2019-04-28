require 'test_helper'

module Proclaim
	class ImagesControllerTest < ActionDispatch::IntegrationTest
		include Engine.routes.url_helpers

		# setup do
		# 	# By default, no one is logged in
		# 	sign_in nil
		# end

		# teardown do
		# 	image = FactoryBot.build(:image, image: nil)
		# 	FileUtils.rm_rf(File.join(Rails.public_path, image.image.cache_dir))
		# 	FileUtils.rm_rf(File.join(Rails.public_path, image.image.store_dir))
		# end

		# test "should create image if logged in" do
		# 	user = FactoryBot.create(:user)
		# 	sign_in user

		# 	post = FactoryBot.create(:post)

		# 	assert_difference('Image.count') do
		# 		post_image post
		# 	end

		# 	# Response should be the URL to the newly stored image
		# 	assert_match image.image.store_dir, @response.body
		# end

		# private

		# def post_image(post)
		# 	post images_url, as: :json, params: {
		# 		image: {
		# 			post_id: post.id,
		# 			image: Rack::Test::UploadedFile.new(File.join(Rails.root, '../', 'support', 'images', 'test.jpg'), "image/jpeg")
		# 		}
		# 	}
		# end
	end
end
