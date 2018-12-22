require 'test_helper'

class PostShowTest < ActionDispatch::IntegrationTest
	self.use_transactional_tests = false

	setup do
		ApplicationController.any_instance.stubs(:current_user).returns(nil)
		ApplicationController.any_instance.stubs(:authenticate_user).returns(false)

		DatabaseCleaner.strategy = :truncation
		DatabaseCleaner.start

		Capybara.current_driver = :selenium

		@show_pag = ShowPage.new
	end

	teardown do
		DatabaseCleaner.clean
		Capybara.use_default_driver
	end

	test "show should include edit/delete buttons if logged in" do
		user = FactoryBot.create(:user)
		sign_in user

		post = FactoryBot.create(:published_post)

		visit proclaim.post_path(post)

		assert page.has_css?('a', text: "Edit"),
		       "The show page should include a link to edit if logged in!"
		assert page.has_css?('a', text: "Delete"),
		       "The show page should include a link to delete if logged in!"
	end

	test "show should not include edit/delete buttons if not logged in" do
		post = FactoryBot.create(:published_post)

		visit proclaim.post_path(post)

		assert page.has_no_css?('a', text: "Edit"),
		       "The show page should not include a link to edit if not logged in!"
		assert page.has_no_css?('a', text: "Delete"),
		       "The show page should not include a link to delete if not logged in!"
	end
end
