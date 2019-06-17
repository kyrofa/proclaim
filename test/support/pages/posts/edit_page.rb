require 'capybara/rails'

module Proclaim
	class EditPage
		include Capybara::DSL

		def set_title(title)
			within('form') do
				element = find('h1.post_title.editable')
				element.click()
				element.set(title)
			end
		end

		def set_subtitle(title)
			within('form') do
				element = find('h2.post_subtitle.editable')
				element.click()
				element.set(title)
			end
		end

		def set_body(body)
			within('form') do
				element = find('div.ql-editor')
				element.click()
				element.set(body)
			end
		end
	end
end
