FactoryGirl.define do
	factory :comment, class: Bespoke::Comment do
		sequence(:author) {|n| "author#{n}"}
		sequence(:title) {|n| "title#{n}"}
		sequence(:body) {|n| "body#{n}"}
		#post
	end
end
