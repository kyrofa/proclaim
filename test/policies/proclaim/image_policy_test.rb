require 'test_helper'

class ImagePolicyTest < ActiveSupport::TestCase
	teardown do
		image = Proclaim::Image.new
		FileUtils.rm_rf(File.join(Rails.public_path, image.image.cache_dir))
		FileUtils.rm_rf(File.join(Rails.public_path, image.image.store_dir))
	end

	test "image scope" do
		user = FactoryBot.create(:user)
		image = FactoryBot.create(:image)

		# Verify that a user can view the image
		images = Pundit.policy_scope(user, Proclaim::Image)
		assert_includes images, image

		# Verify that a guest cannot see any images
		images = Pundit.policy_scope(nil, Proclaim::Image)
		assert_empty images
	end

	test "image caching" do
		user = FactoryBot.create(:user)
		image = FactoryBot.build(:image)

		# Verify that a user can cache an image
		policy = Proclaim::ImagePolicy.new(user, image)
		assert policy.cache?, "A user should be able to cache images"

		# Verify that a guest cannot cache an image
		policy = Proclaim::ImagePolicy.new(nil, image)
		refute policy.cache?, "A guest should not be able to cache images"
	end

	test "image creation" do
		user = FactoryBot.create(:user)
		image = FactoryBot.build(:image)

		# Verify that a user can create an image
		policy = Proclaim::ImagePolicy.new(user, image)
		assert policy.create?, "A user should be able to create images"

		# Verify that a guest cannot create an image
		policy = Proclaim::ImagePolicy.new(nil, image)
		refute policy.create?, "A guest should not be able to create images"
	end

	test "image discard" do
		user = FactoryBot.create(:user)
		cached_image = FactoryBot.build(:image)
		saved_image = FactoryBot.create(:image)

		# Verify that a user can discard a cached image
		policy = Proclaim::ImagePolicy.new(user, cached_image)
		assert policy.discard?, "A user should be able to discard a cached image"

		# Verify that a user can discard a saved image
		policy = Proclaim::ImagePolicy.new(user, saved_image)
		assert policy.discard?, "A user should be able to discard a saved image"

		# Verify that a guest cannot discard a cached image
		policy = Proclaim::ImagePolicy.new(nil, cached_image)
		refute policy.discard?, "A guest should not be able to discard a cached image"

		# Verify that a guest cannot discard a saved image
		policy = Proclaim::ImagePolicy.new(nil, saved_image)
		refute policy.discard?, "A guest should not be able to discard a saved image"
	end

	test "image destroy" do
		user = FactoryBot.create(:user)
		image = FactoryBot.create(:image)

		# Verify that a user can destroy an image
		policy = Proclaim::ImagePolicy.new(user, image)
		assert policy.destroy?, "A user should be able to destroy image"

		# Verify that a guest cannot destroy an image
		policy = Proclaim::ImagePolicy.new(nil, image)
		refute policy.destroy?, "A guest should not be able to destroy image"
	end
end
