class CreateBespokeCommentHierarchies < ActiveRecord::Migration
	def change
		create_table :bespoke_comment_hierarchies, :id => false do |t|
			# ID of the parent/grandparent/great-grandparent/etc. comments
			t.integer  :ancestor_id, null: false

			# ID of the target comment
			t.integer  :descendant_id, null: false

			# Number of generations between the ancestor and the descendant.
			# Parent/child = 1, for example.
			t.integer  :generations, null: false
		end

		# For "all progeny of…" and leaf selects:
		add_index :bespoke_comment_hierarchies,
		          [:ancestor_id, :descendant_id, :generations],
		          :unique => true,
		          :name => "comment_anc_desc_udx"

		# For "all ancestors of…" selects,
		add_index :bespoke_comment_hierarchies,
		          [:descendant_id],
		          :name => "comment_desc_idx"
	end
end
