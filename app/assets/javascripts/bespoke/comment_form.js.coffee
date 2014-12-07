class CommentForm
	constructor: (@commentContainerClass, @commentFormClass,
	              @cancelCommentButtonClass, @replyLinkClass,
	              @deleteLinkClass) ->
		if (@commentContainerClass.length > 0) and
		   (@commentFormClass.length > 0) and
		   (@cancelCommentButtonClass.length > 0) and
		   (@replyLinkClass.length > 0) and
		   (@deleteLinkClass.length > 0)
			@cleanBindings()
			@addBindings()
		else
			console.error("Invalid length for comment classes!")

	addBindings: ->
		$(document).on "click", @replyLinkClass, @showCommentForm
		$(document).on "click", @cancelCommentButtonClass, @cancelComment

		$(document).on "ajax:beforeSend", @commentFormClass, @handleCommentStarted
		$(document).on "ajax:complete", @commentFormClass, @handleCommentFinished

		$(document).on "ajax:success", @commentFormClass, @handleCommentSuccess
		$(document).on "ajax:error", @commentFormClass, @handleCommentFailure

		$(document).on "ajax:success", @deleteLinkClass, @handleDeleteCommentSuccess
		$(document).on "ajax:error", @deleteLinkClass, @handleDeleteCommentFailure

	cleanBindings: ->
		$(document).off "click", @replyLinkClass
		$(document).off "click", @cancelCommentButtonClass

		$(document).off "ajax:beforeSend", @commentFormClass
		$(document).off "ajax:complete", @commentFormClass

		$(document).off "ajax:success", @commentFormClass
		$(document).off "ajax:error", @commentFormClass

		$(document).off "ajax:success", @deleteLinkClass
		$(document).off "ajax:error", @deleteLinkClass

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

		@removeForm form

	handleCommentSuccess: (event, data, status, xhr) =>
		target = $($(event.target).data("target"))
		if target.length == 1
			if data.html.length > 0
				target.append(data.html)

				# Hide form, but don't remove so events can still be emitted
				@removeForm $(event.target), true
			else
				console.error("Invalid comment HTML!")
		else
			console.error("Invalid comment target!")

	handleCommentFailure: (event, xhr, status, error) =>
		console.log("Failure!")
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
		commentContainer = $(event.target).closest(@commentContainerClass)
		if commentContainer.length == 1
			commentContainer.fadeOut ->
				commentContainer.remove()
		else
			console.error("No comment container for removal!")

	handleDeleteCommentFailure: (event, xhr, status, error) =>
		console.error("Unable to delete comment!")

	showCommentForm: (event) =>
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

			target.append(form)

	cancelComment: (event) =>
		event.preventDefault()

		@removeForm $(event.target).closest(@commentFormClass)

	removeForm: (form, hideInsteadOfRemove = false) ->
		if form.length == 0
			console.error("Invalid comment form length for removal!")
			return

		# Don't remove the main comment form-- just clear it
		if form.hasClass("main_comment_form")
			form.each (index, element) ->
				element.reset()
		else
			if (hideInsteadOfRemove)
				form.hide()
			else
				form.remove()

# Make available to other scripts
@CommentForm = CommentForm
