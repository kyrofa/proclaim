module Proclaim
	class ApplicationMailer < ActionMailer::Base
		default from: Proclaim.mailer_sender || default_params[:from] || "from@example.com"
	end
end
