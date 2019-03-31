class Editor
	constructor: (@form, @titleFormField, @titleEditableItem,
	              @bodyFormField, @bodyEditableItem, @toolbarButtons) ->
		if (@form.length == 1) and (@titleFormField.length == 1) and
		   (@titleEditableItem.length == 1) and (@bodyFormField.length == 1) and
		   (@bodyEditableItem.length == 1)
			imageUploadPath = @bodyEditableItem.data("image-upload-path")
			imageDeletePath = @bodyEditableItem.data("image-delete-path")

			if (imageUploadPath.length > 0) and (imageDeletePath.length > 0)
				@bodyEditor = new MediumEditor(@bodyEditableItem, {
					buttonLabels: 'fontawesome',
					buttons: @toolbarButtons
				})

				@titleEditor = new MediumEditor(@titleEditableItem)

				@bodyEditableItem.mediumInsert({
					editor: @bodyEditor,
					addons: {
						images: {
							imagesUploadScript: imageUploadPath,
							imagesDeleteScript: imageDeletePath,
							deleteFile: (file, that) =>
								$.post that.options.imagesDeleteScript, {file: file}, (data, status, jqxhr) =>
									if data.id
										@form.append('<input type="hidden" name="post[images_attributes][' + data.id + '][id]" value="' + data.id + '" />')
										@form.append('<input type="hidden" name="post[images_attributes][' + data.id + '][_destroy]" value="true" />')
								, "json"
						}
					}
				})

				@cleanBindings()
				@addBindings()
			else
				console.error("Missing image upload and/or image delete paths for body editor!")
		else
			console.error("Invalid length for editable items or form fields!")

	addBindings: ->
		@form.on "submit", @updateFormFields

	cleanBindings: ->
		@form.off "submit"

	updateFormFields: (event) =>
		@titleFormField.val(@titleEditor.serialize()["element-0"].value)
		@bodyFormField.val(@bodyEditor.serialize()["element-0"].value)

# Make available to other scripts
@Editor = Editor
