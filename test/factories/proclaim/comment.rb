FactoryBot.define do
	factory :comment, class: Proclaim::Comment do
		sequence(:author) {|n| "comment#{n} author"}
		sequence(:body) {|n| "comment#{n} body"}
		post

		factory :published_comment do
			association :post, factory: :published_post
		end
	end
end
