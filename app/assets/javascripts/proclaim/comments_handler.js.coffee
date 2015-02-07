class CommentsHandler
	constructor: (@discussionClass, @commentClass, @commentFormClass,
	              @mainCommentFormClass, @cancelCommentButtonClass,
	              @replyLinkClass, @updateLinkClass, @deleteLinkClass,
	              @subscribeCheckboxClass, @subscribeEmailClass) ->
		if (@discussionClass.length > 0) and
		   (@commentClass.length > 0) and
		   (@commentFormClass.length > 0) and
		   (@mainCommentFormClass.length > 0) and
		   (@cancelCommentButtonClass.length > 0) and
		   (@replyLinkClass.length > 0) and
		   (@updateLinkClass.length > 0) and
		   (@deleteLinkClass.length > 0) and
		   (@subscribeCheckboxClass.length > 0) and
		   (@subscribeEmailClass.length > 0)
			@cleanBindings()
			@addBindings()
		else
			console.error("Invalid length for comment classes!")

	addBindings: ->
		$(document).on "click", @replyLinkClass, @showNewCommentForm
		$(document).on "click", @updateLinkClass, @showUpdateCommentForm
		$(document).on "click", @cancelCommentButtonClass, @cancelComment

		$(document).on "ajax:beforeSend", @commentFormClass, @handleCommentStarted
		$(document).on "ajax:complete", @commentFormClass, @handleCommentFinished

		$(document).on "ajax:success", @commentFormClass, @handleCommentSuccess
		$(document).on "ajax:error", @commentFormClass, @handleCommentFailure

		$(document).on "ajax:success", @deleteLinkClass, @handleDeleteCommentSuccess
		$(document).on "ajax:error", @deleteLinkClass, @handleDeleteCommentFailure

		$(document).on "change", @subscribeCheckboxClass, @handleSubscribeCheckbox

	cleanBindings: ->
		$(document).off "click", @replyLinkClass
		$(document).off "click", @updateLinkClass
		$(document).off "click", @cancelCommentButtonClass

		$(document).off "ajax:beforeSend", @commentFormClass
		$(document).off "ajax:complete", @commentFormClass

		$(document).off "ajax:success", @commentFormClass
		$(document).off "ajax:error", @commentFormClass

		$(document).off "ajax:success", @deleteLinkClass
		$(document).off "ajax:error", @deleteLinkClass

		$(document).off "change", @subscribeCheckboxClass

	# Disable the form until the new comment has been processed
	handleCommentStarted: (event, xhr, settings) =>
		form = $(event.target)
		form.find(":input").prop("disabled", true);
		form.before('<div class = "loading" style = "width: 100px;"></div>')

	handleCommentFinished: (event, xhr, status) =>
		form = $(event.target)
		target = $(form.data("target"))
		form.find(":input").prop("disabled", false);
		form.siblings('div.loading').remove()

		if status == "success"
			@removeForm form

	handleCommentSuccess: (event, data, status, xhr) =>
		if data.html.length == 0
			console.error("Invalid comment HTML!")
			return

		form = $(event.target)

		if form.hasClass("edit_comment")
			form.closest(@discussionClass).replaceWith(data.html)
		else
			target = $(form.data("target"))
			if target.length == 1
				target.append(data.html)
			else
				console.error("Invalid comment target!")
				return

			# Hide form, but don't remove so events can still be emitted
			@removeForm form, true

	handleCommentFailure: (event, xhr, status, error) =>
		$(event.target).siblings("div.error").remove()
		errorMessage = "<div class='error'>"
		errorMessage += "<strong>The following errors have prevented this comment from being saved:</strong>"
		errorMessage += "<ul>"
		for error in $.parseJSON(xhr.responseText)
			errorMessage += "<li>" + error + "</li>"
		errorMessage += "</ul>"
		errorMessage += "</div>"
		$(event.target).before(errorMessage)

	handleDeleteCommentSuccess: (event, data, status, xhr) =>
		commentContainer = $(event.target).closest(@discussionClass)
		if commentContainer.length == 1
			commentContainer.fadeOut ->
				commentContainer.remove()
		else
			console.error("No comment container for removal!")

	handleDeleteCommentFailure: (event, xhr, status, error) =>
		console.error("Unable to delete comment!")

	showNewCommentForm: (event) =>
		event.preventDefault()

		target = $($(event.target).data("target"))
		if target.length != 1
			console.error("Invalid comment target data!")
			return

		# Ensure form isn't already shown. If it is, don't show it again
		if target.children(@commentFormClass).length == 0
			form = $(event.target).data("form")
			if form.length == 0
				console.error("Invalid comment form data!")
				return

			# Remove all other non-main forms-- make this form exclusive
			other_forms = $(document).find(@commentFormClass).not(@mainCommentFormClass)
			if other_forms.length > 0
				@removeForm other_forms

			target.append(form)
			form = target.children(@commentFormClass)
			form.addClass("new_comment")

			form.children(@cancelCommentButtonClass).focus();
			form.children("input:text:visible:first").focus();

	showUpdateCommentForm: (event) =>
		event.preventDefault()

		target = $(event.target)

		form = target.data("form")
		if form.length == 0
			console.error("Invalid comment form data!")
			return

		discussion = target.closest(@discussionClass)
		target.closest(@commentClass).hide()
		discussion.prepend(form)
		form = discussion.children(@commentFormClass)
		form.addClass("edit_comment")
		form.children(@cancelCommentButtonClass).focus();
		form.children("input:text:visible:first").focus();

	cancelComment: (event) =>
		event.preventDefault()

		form = $(event.target).closest(@commentFormClass)
		if form.hasClass("edit_comment")
			form.siblings(@commentClass).show()

		$(event.target).siblings(@subscribeEmailClass).hide()
		@removeForm form

	handleSubscribeCheckbox: (event) =>
		if event.target.checked
			$(event.target).siblings(@subscribeEmailClass).show()
		else
			$(event.target).siblings(@subscribeEmailClass).val("")
			$(event.target).siblings(@subscribeEmailClass).hide()

	removeForm: (form, hideInsteadOfRemove = false) ->
		if form.length == 0
			console.error("Invalid comment form length for removal!")
			return

		form.siblings("div.error").remove() # If any

		form.each (index, element) =>
			thisForm = $(element)

			# Hide the email field
			thisForm.children(@subscribeEmailClass).hide()

			# Don't remove the main comment form-- just clear it
			if thisForm.is(@mainCommentFormClass)
				element.reset()
			else
				if (hideInsteadOfRemove)
					thisForm.hide()
				else
					thisForm.remove()

# Make available to other scripts
@CommentsHandler = CommentsHandler
