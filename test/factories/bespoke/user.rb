FactoryGirl.define do
	factory :user, class: Bespoke::User do
		sequence(:first_name) {|n| "first_name#{n}"}
		sequence(:last_name) {|n| "first_name#{n}"}
	end
end
