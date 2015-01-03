require 'test_helper'

class PostFormTest < ActionDispatch::IntegrationTest
	include WaitForAjax
	self.use_transactional_fixtures = false

	setup do
		ApplicationController.any_instance.stubs(:current_user).returns(nil)
		ApplicationController.any_instance.stubs(:authenticate_user).returns(false)

		DatabaseCleaner.strategy = :truncation
		DatabaseCleaner.start

		Capybara.current_driver = :selenium

		@edit_page = EditPage.new
	end

	teardown do
		DatabaseCleaner.clean
		Capybara.use_default_driver

		image = Bespoke::Image.new
		FileUtils.rm_rf(File.join(Rails.public_path, image.image.cache_dir))
		FileUtils.rm_rf(File.join(Rails.public_path, image.image.store_dir))
	end

	test "should create post" do
		user = FactoryGirl.create(:user)
		sign_in user

		visit bespoke.new_post_path

		within('#new_post') do
			element = find('h1.editable')
			element.click()
			element.set("Post Title") # Set the title text
			element = find('div.editable')
			element.click() # Select the element
			element.set("Paragraph 1\nParagraph 2") # Set the body text
		end

		assert_difference('Bespoke::Post.count') do
			click_button "Create"
			assert page.has_text? "Post Title"
			assert page.has_text? "Paragraph 1\nParagraph 2"
			wait_for_ajax
		end
	end

	test "should delete cached image" do
		user = FactoryGirl.create(:user)
		sign_in user

		image = FactoryGirl.build(:image, post: nil)
		post = FactoryGirl.create(:post, body: @edit_page.medium_inserted_image_html(image))

		cache_file_path = File.join(Rails.public_path, image.image.cache_dir, image.image.cache_name)
		cache_path = File.dirname(cache_file_path)

		assert File.exist?(cache_file_path), "File should have been cached: #{cache_file_path}"

		visit bespoke.edit_post_path(post)

		find("img[src='#{image.image.url}']").hover
		find("a.mediumInsert-imageRemove").click

		assert page.has_no_css?("img[src='#{image.image.url}']"), "Image should have been removed!"

		wait_for_ajax

		refute File.exist?(cache_file_path), "Should have removed cache file: #{cache_file_path}"
		refute File.exist?(cache_path), "Should have removed cache path: #{cache_path}"
	end

	test "should delete saved image" do
		user = FactoryGirl.create(:user)
		sign_in user

		image = FactoryGirl.create(:image)
		image.post.body = "<p>test</p>" + @edit_page.medium_inserted_image_html(image)
		image.post.save

		save_path = File.join(Rails.public_path, image.image.store_dir)
		saved_file_path = File.join(save_path, image.image_identifier)

		assert File.exist?(saved_file_path), "File should be saved: #{saved_file_path}"

		visit bespoke.edit_post_path(image.post)

		find("img[src='#{image.image.url}']").hover
		find("a.mediumInsert-imageRemove").click

		assert page.has_no_css?("img[src='#{image.image.url}']"), "Image should have been removed!"

		wait_for_ajax

		assert File.exist?(saved_file_path), "File should still be saved: #{saved_file_path}"

		click_button "Update Post"
		assert page.has_no_css?("div#error_explanation"), "This update should have succeeded!"

		assert page.has_no_css?("img[src='#{image.image.url}']"), "Image should still be removed!"

		refute File.exist?(saved_file_path), "Should have removed file: #{saved_file_path}"
		refute File.exist?(save_path), "Should have removed saved path: #{save_path}"
	end

	test "delete saved image but not save should still show image" do
		user = FactoryGirl.create(:user)
		sign_in user

		image = FactoryGirl.create(:image)
		image.post.body = @edit_page.medium_inserted_image_html(image)
		image.post.save

		save_path = File.join(Rails.public_path, image.image.store_dir)
		saved_file_path = File.join(save_path, image.image_identifier)

		assert File.exist?(saved_file_path), "File should be saved: #{saved_file_path}"

		visit bespoke.edit_post_path(image.post)

		find("img[src='#{image.image.url}']").hover
		find("a.mediumInsert-imageRemove").click

		assert page.has_no_css?("img[src='#{image.image.url}']"), "Image should have been removed!"

		wait_for_ajax

		assert File.exist?(saved_file_path), "File should still be saved: #{saved_file_path}"

		# Don't save. Just visit the post's show page
		visit bespoke.post_path(image.post)

		assert page.has_css?("img[src='#{image.image.url}']"), "Image should still be present!"
		assert File.exist?(saved_file_path), "File should still be saved: #{saved_file_path}"
	end

	test "should show error without title" do
		user = FactoryGirl.create(:user)
		sign_in user

		visit bespoke.new_post_path

		within('#new_post') do
			# Don't fill in title
			element = find('div.editable')
			element.click() # Select the element
			element.set("Paragraph 1\nParagraph 2") # Set the text
		end

		assert_no_difference('Bespoke::Post.count') do
			click_button "Create"
			assert page.has_css? "div#error_explanation"
			wait_for_ajax
		end
	end

	test "should show error without body" do
		user = FactoryGirl.create(:user)
		sign_in user

		visit bespoke.new_post_path

		within('#new_post') do
			element = find('h1.editable')
			element.click()
			element.set("Post Title") # Set the title text
			# Don't fill in the body
		end

		assert_no_difference('Bespoke::Post.count') do
			click_button "Create"
			assert page.has_css? "div#error_explanation"
			wait_for_ajax
		end
	end
end
