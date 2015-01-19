Proclaim.setup do |config|
	# The class to which posts belong. Changing this also changes the
	# `current_author_method` and `authentication_method`. For example, setting
	# `author_class = "Admin"` changes the default `current_author_method` to be
	# `:current_admin`, etc.
	#config.author_class = "User"

	# Method to obtain the name of the author. This should be a method on the
	# author class.
	#config.author_name_method = :name

	# Method to obtain the currently-authenticated user. Should return nil if
	# no user is currently authenticated.
	#config.current_author_method = :current_user

	# Method to verify that a user is authenticated, and if not, will redirect
	# to some sort of authentication page.
	#config.authentication_method = :authenticate_user!

	# Maximum length for the excerpts shown on the posts index.
	#config.excerpt_length = 500

	# Buttons to display on post editor toolbar
	#config.editor_toolbar_buttons = ['bold', 'italic', 'underline', 'anchor',
	#                                 'header1', 'header2', 'quote']

	# Whitelist of HTML tags to be supported by the editor
	#config.editor_whitelist_tags = %w(h1 h2 h3 h4 h5 h6
	#                                  div p blockquote
	#                                  ul ol li
	#                                  a b strong i u
	#                                  img figure
	#                                  pre sup sub br)

	# Whitelist of HTML attributes to be supported by the editor
	#config.editor_whitelist_attributes = %w(class id style href title src alt
	#                                        align draggable)

	# Email address to use in the "from" field of all emails
	#config.mailer_sender = '"My Blog" <blog@example.com>'
end
