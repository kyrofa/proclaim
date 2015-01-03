FactoryGirl.define do
	factory :comment, class: Proclaim::Comment do
		sequence(:author) {|n| "author#{n}"}
		sequence(:body) {|n| "body#{n}"}
		post

		factory :published_comment do
			association :post, factory: :published_post
		end
	end
end
