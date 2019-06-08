FactoryBot.define do
	factory :subscription, class: Proclaim::Subscription do
		sequence(:name) {|n| "name#{n}"}
		sequence(:email) {|n| "email#{n}@example.com"}

		factory :post_comment_subscription do
			comment
		end

		factory :published_post_comment_subscription do
			association :comment, factory: :published_comment
		end
	end
end
