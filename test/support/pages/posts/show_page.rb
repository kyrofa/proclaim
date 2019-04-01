class ShowPage
	include Capybara::DSL

	def comment_reply_link(comment)
		find("#comment_#{comment.id} .reply")
	end

	def comment_edit_link(comment)
		find("#comment_#{comment.id} .edit")
	end

	def comment_delete_link(comment)
		find("#comment_#{comment.id} .delete")
	end

	def edit_comment_submit_button(comment)
		find("#edit_comment_#{comment.id} input[type=submit]")
	end

	def new_comment_submit_button(comment = nil)
		if comment
			find("#reply_to_#{comment.id}_new_comment input[type=submit]")
		else
			find('#new_comment input[type=submit]')
		end
	end

	def edit_comment_cancel_button(comment)
		find("#edit_comment_#{comment.id} button.cancel_comment")
	end

	def new_comment_cancel_button(comment = nil)
		if comment
			find("#reply_to_#{comment.id}_new_comment button.cancel_comment")
		else
			find('#new_comment button.cancel_comment')
		end
	end

	def antispam_solution(comment = nil)
		if comment
			find("input#reply_to_#{comment.id}_antispam_solution", visible: false).value
		else
			find('input#antispam_solution', visible: false).value
		end
	end
end
