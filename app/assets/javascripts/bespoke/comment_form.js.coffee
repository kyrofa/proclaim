class CommentForm
	constructor: (@replyLinkClass) ->
		if @replyLinkClass.length > 0
			@addBindings
		else
			console.log("Invalid length for reply link class")

	addBindings: ->
		$(@replyLinkClass).on "click", @showCommentForm

	showCommentForm: (target) ->
		console.log("test")

# Make available to other scripts
@CommentForm = CommentForm
