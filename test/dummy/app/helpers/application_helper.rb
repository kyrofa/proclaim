module ApplicationHelper
	def bootstrapClassFor(flashType)
		case flashType.to_sym
			when :success
				return "alert-success"
			when :error
				return "alert-danger"
			when :alert
				return "alert-warning"
			when :notice
				return "alert-info"
			else
				return flashType.to_s
		end
	end

	def flashMessages(opts = {})
		flash.each do |messageType, message|
			concat(content_tag(:div,
			                   message,
			                   class: "alert #{bootstrapClassFor(messageType)} fade in") do
				concat message
			end)
		end

		return nil
	end
end
