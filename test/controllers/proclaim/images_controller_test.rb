require 'test_helper'

module Proclaim
	class ImagesControllerTest < ActionController::TestCase
		setup do
			@routes = Engine.routes

			@controller.stubs(:current_user).returns(nil)
			@controller.stubs(:authenticate_user).returns(false)
		end

		teardown do
			image = FactoryBot.build(:image, image: nil)
			FileUtils.rm_rf(File.join(Rails.public_path, image.image.cache_dir))
			FileUtils.rm_rf(File.join(Rails.public_path, image.image.store_dir))
		end

		test "should create image if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			image = FactoryBot.build(:image, image: nil)

			assert_difference('Image.count') do
				post :create, format: :json, image: {
					post_id: image.post_id,
					image: Rack::Test::UploadedFile.new(File.join(Rails.root, '../', 'support', 'images', 'test.jpg'))
				}
			end

			# Response should be the URL to the newly stored image
			assert_match image.image.store_dir, @response.body
		end

		test "should not create image if not logged in" do
			image = FactoryBot.build(:image, image: nil)

			assert_no_difference('Image.count') do
				post :create, format: :json, image: {
					post_id: image.post_id,
					image: Rack::Test::UploadedFile.new(File.join(Rails.root, '../', 'support', 'images', 'test.jpg'))
				}
			end

			assert_response :unauthorized
		end

		test "should not create image without a post" do
			user = FactoryBot.create(:user)
			sign_in user

			image = FactoryBot.build(:image, post: nil, image: nil)

			assert_no_difference('Image.count') do
				post :create, format: :json, image: {
					image: Rack::Test::UploadedFile.new(File.join(Rails.root, '../', 'support', 'images', 'test.jpg'))
				}
			end

			assert_response :unprocessable_entity
		end

		test "should not create image without actual image" do
			user = FactoryBot.create(:user)
			sign_in user

			image = FactoryBot.build(:image, image: nil)

			assert_no_difference('Image.count') do
				post :create, format: :json, image: {
					post_id: image.post_id
				}
			end

			assert_response :unprocessable_entity
		end

		test "should cache image if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			image = FactoryBot.build(:image, image: nil)

			# This is only caching! No new image should be inserted into the database
			assert_no_difference('Image.count', "Caching shouldn't create new images!") do
				post :cache, format: :json, file: Rack::Test::UploadedFile.new(test_image_file_path)
			end

			# Response should be the URL to the newly cached image
			assert_match image.image.cache_dir, @response.body
		end

		test "should not cache image if not logged in" do
			assert_no_difference('Image.count') do
				post :cache, format: :json, file: Rack::Test::UploadedFile.new(test_image_file_path)
			end

			assert_response :unauthorized
		end

		test "should discard image if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			image = FactoryBot.build(:image)

			# This is only discarding from the cache! No images should be removed
			# from the database.
			assert_no_difference('Image.count', "Discarding shouldn't remove images!") do
				post :discard, format: :json, file: image.image.url
			end

			assert_response :success
		end

		test "should not discard image if not logged in" do
			image = FactoryBot.build(:image)

			assert_no_difference('Image.count') do
				post :discard, format: :json, file: image.image.url
			end

			assert_response :unauthorized
		end

		test "discard should not destroy image if logged in but return ID" do
			user = FactoryBot.create(:user)
			sign_in user

			image = FactoryBot.create(:image)

			assert_no_difference('Image.count', -1) do
				post :discard, format: :json, file: image.image.url
			end

			assert_response :success
			assert_not_nil @response.body
			json = JSON.parse(@response.body)

			assert_equal image.id.to_s, json["id"]
		end

		test "should destroy image if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			image = FactoryBot.create(:image)

			assert_difference('Image.count', -1) do
				delete :destroy, format: :json, id: image.id
			end

			assert_response :success
		end

		test "should not destroy image if not logged in" do
			image = FactoryBot.create(:image)

			assert_no_difference('Image.count') do
				delete :destroy, format: :json, id: image.id
			end

			assert_response :unauthorized
		end
	end
end
