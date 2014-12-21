class CreateBespokeImages < ActiveRecord::Migration
  def change
    create_table :bespoke_images do |t|
      t.belongs_to :post, index: true
      t.string :image

      t.timestamps null: false
    end

    add_foreign_key :bespoke_images, :posts
  end
end
