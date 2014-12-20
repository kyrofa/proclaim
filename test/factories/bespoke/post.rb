FactoryGirl.define do
	factory :post, class: Bespoke::Post do
		sequence(:title) {|n| "title#{n}"}
		sequence(:body) {|n| "body#{n}"}
		published false
		association :author, factory: :user

		factory :published_post do
			published true
			publication_date Date.today
		end
	end
end
