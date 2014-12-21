FactoryGirl.define do
	factory :image, class: Bespoke::Image do
		post
		image { Rack::Test::UploadedFile.new(test_image_file_path) }
	end
end
