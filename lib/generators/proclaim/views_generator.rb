require 'rails/generators/base'

module Proclaim
	module Generators
		class ViewsGenerator < Rails::Generators::Base
			source_root File.expand_path("../../../../app/views/proclaim", __FILE__)

			desc "Copy all Proclaim views into application"

			def copy_views
				if options[:views]
					options[:views].each do |directory|
						directory directory.to_sym, "app/views/proclaim/#{directory}"
					end
				else
					directory :comments, "app/views/proclaim/comments"
					directory :posts, "app/views/proclaim/posts"
					directory :subscription_mailer, "app/views/proclaim/subscription_mailer"
					directory :subscriptions, "app/views/proclaim/subscriptions"
				end
			end
		end
	end
end
