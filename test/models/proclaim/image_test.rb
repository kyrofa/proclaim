# == Schema Information
#
# Table name: proclaim_images
#
#  id         :integer          not null, primary key
#  post_id    :integer
#  image      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

module Proclaim
	class ImageTest < ActiveSupport::TestCase
		teardown do
			image = Image.new
			FileUtils.rm_rf(File.join(Rails.public_path, image.image.cache_dir))
			FileUtils.rm_rf(File.join(Rails.public_path, image.image.store_dir))
		end

		test "ensure factory is good" do
			image = FactoryBot.build(:image)

			assert image.save, "Factory needs to be updated to save successfully"
		end

		test "ensure post is required" do
			image = FactoryBot.build(:image, post_id: nil)

			refute image.save, "Image should require a post_id!"
		end

		test "ensure post validity is verified" do
			# Post with 12345 shouldn't exist
			image = FactoryBot.build(:image, post_id: 12345)

			refute image.save, "Image should require a valid post!"
		end

		test "ensure image is required" do
			image = FactoryBot.build(:image, image: nil)

			refute image.save, "Image should require an image to be uploaded!"
		end

		test "ensure image is cached, saved, and removed correctly" do
			image = FactoryBot.build(:image)

			cache_file_path = File.join(Rails.public_path, image.image.cache_dir, image.image.cache_name)
			cache_path = File.dirname(cache_file_path)

			assert File.exist?(cache_file_path), "File should have been cached: #{cache_file_path}"

			assert image.save, "Image should have saved!"

			save_path = File.join(Rails.public_path, image.image.store_dir)
			saved_file_path = File.join(save_path, image.image_identifier)

			assert File.exist?(saved_file_path), "File should be saved: #{saved_file_path}"
			refute File.exist?(cache_file_path), "Should have removed cache file: #{cache_file_path}"
			refute File.exist?(cache_path), "Should have removed cache path: #{cache_path}"

			assert image.destroy

			refute File.exist?(saved_file_path), "Should have removed file: #{saved_file_path}"
			refute File.exist?(save_path), "Should have removed saved path: #{save_path}"
		end
	end
end
