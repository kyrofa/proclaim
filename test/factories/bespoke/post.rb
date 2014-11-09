FactoryGirl.define do
	factory :post, class: Bespoke::Post do
		sequence(:title) {|n| "title#{n}"}
		sequence(:body) {|n| "body#{n}"}
		association :author, factory: :user
	end
end
