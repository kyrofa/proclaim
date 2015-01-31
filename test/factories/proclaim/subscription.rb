FactoryGirl.define do
	factory :subscription, class: Proclaim::Subscription do
		sequence(:name) {|n| "name#{n}"}
		sequence(:email) {|n| "email#{n}@example.com"}

		factory :post_subscription do
			post
		end

		factory :published_post_subscription do
			association :post, factory: :published_post
		end
	end
end
