FactoryGirl.define do
	factory :post, class: Proclaim::Post do
		sequence(:title) {|n| "post#{n} title"}
		sequence(:body) {|n| "post#{n} body"}
		association :author, factory: :user

		factory :published_post do
			# Also called upon create
			after(:build) do |post, evaluator|
				post.publish
			end
		end
	end
end
