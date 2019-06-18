Proclaim.setup do |config|
	# The class to which posts belong. Changing this also changes the
	# `current_author_method` and `authentication_method`. For example, setting
	# `author_class = "Admin"` changes the default `current_author_method` to be
	# `:current_admin`, etc.
	# config.author_class = "User"

	# Method to obtain the name of the author. This should be a method on the
	# author class.
	# config.author_name_method = :name

	# Method to obtain the currently-authenticated user. Should return nil if
	# no user is currently authenticated.
	# config.current_author_method = :current_user

	# Method to verify that a user is authenticated, and if not, will redirect
	# to some sort of authentication page.
	# config.authentication_method = :authenticate_user!

	# Maximum length for the excerpts shown on the posts index.
	# config.excerpt_length = 500

	# Buttons to display on post editor toolbar
	# config.editor_toolbar = [
	# 	['bold', 'italic', 'underline', 'strike', 'code'],
	# 	[{ 'header': 1 }, { 'header': 2 }],
	# 	['code-block'],
	# 	[{ 'align': []}],
	# 	[{ 'list': 'ordered'}, { 'list': 'bullet'}],
	# 	['link', 'image', 'video', 'formula']
	# ]

	# Formats to allow in the editor (can be a superset of the toolbar)
	# config.editor_formats = [
	# 	'align', 'blockquote', 'bold', 'code', 'code-block', 'formula', 'header',
	# 	'image', 'indent', italic', 'link', 'list', 'strike', 'underline', 'video'
	# ]

	# Email address to use in the "from" field of all emails
	# config.mailer_sender = '"My Blog" <blog@example.com>'

	# The secret key used by Proclaim for subscription tokens. Changing this will
	# invalidate any tokens already generated, making it impossible to unsubscribe from
	# old links. Proclaim will use the `secret_key_base` as its `secret_key` by default.
	# You can change it below and use your own secret key.
	# config.secret_key = '<%= SecureRandom.hex(64) %>'

	# Register a callback to be called when a post is published
	# config.after_post_published do |post|
	#	puts "A post was just published!"
	# end

	# Register a callback to be called when a new comment is created
	# config.after_new_comment do |comment|
	#	puts "A new comment was just made!"
	# end

	# Register a callback to be called when a new subscription is created
	# config.after_new_subscription do |subscription|
	#	puts "A new subscription was just created!"
	# end
end
