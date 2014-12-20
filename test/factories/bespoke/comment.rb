FactoryGirl.define do
	factory :comment, class: Bespoke::Comment do
		sequence(:author) {|n| "author#{n}"}
		sequence(:title) {|n| "title#{n}"}
		sequence(:body) {|n| "body#{n}"}
		post

		factory :published_comment do
			association :post, factory: :published_post
		end
	end
end
