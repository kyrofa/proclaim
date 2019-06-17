class Editor
	constructor: (@form, @titleFormField, @titleEditableItem, @titleContents,
		          @subtitleFormField, @subtitleEditableItem, @subtitleContents,
		          @bodyFormField, @quillBodyFormField, @bodyEditableItem,
		          @bodyScrollingContainer, @bodyContents, @toolbar, @formats) ->
		if (@form.length == 1) and (@titleFormField.length == 1) and
		   (@titleEditableItem.length == 1) and (@subtitleFormField.length == 1) and
		   (@subtitleEditableItem.length == 1)and (@bodyFormField.length == 1) and
		   (@bodyEditableItem.length == 1) and (@bodyScrollingContainer.length == 1)
			@bodyEditor = new Quill(@bodyEditableItem.get(0), {
				placeholder: @bodyEditableItem.data("placeholder"),
				scrollingContainer: @bodyScrollingContainer.get(0),
				theme: 'bubble',
				formats: @formats,
				modules: {
					toolbar: @toolbar,
				}
			})
			@bodyEditor.setContents(@bodyContents)

			@cleanBindings()
			@addBindings()
		else
			console.error("Invalid length for editable items or form fields!")

	addBindings: ->
		@form.on "submit", @updateFormFields
		@titleEditableItem.on "paste", @stripFormatting
		@titleEditableItem.on "keypress", @disallowNewlines
		@subtitleEditableItem.on "paste", @stripFormatting
		@subtitleEditableItem.on "keypress", @disallowNewlines

	cleanBindings: ->
		@form.off "submit"
		@titleEditableItem.off "paste"
		@titleEditableItem.off "keypress"
		@subtitleEditableItem.off "paste"
		@subtitleEditableItem.off "keypress"

	updateFormFields: (event) =>
		@titleFormField.val(@titleEditableItem.text())
		@subtitleFormField.val(@subtitleEditableItem.text())
		@quillBodyFormField.val(JSON.stringify(@bodyEditor.getContents()))
		@bodyFormField.val(@bodyEditableItem.children('div.ql-editor').html())

	stripFormatting: (event) =>
		event.stopPropagation()
		event.preventDefault()

		clipboardData = event.clipboardData || window.clipboardData || event.originalEvent.clipboardData
		pastedData = clipboardData.getData('Text')

		# Strip formatting out by setting HTML and then using the resulting text
		event.currentTarget.innerHTML = pastedData
		event.currentTarget.innerHTML = event.currentTarget.innerText

	disallowNewlines: (event) =>
		return event.which != 13;


# Make available to other scripts
@Editor = Editor
