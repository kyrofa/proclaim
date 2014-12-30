# == Schema Information
#
# Table name: bespoke_images
#
#  id         :integer          not null, primary key
#  post_id    :integer
#  image      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Bespoke
	class Image < ActiveRecord::Base
		belongs_to :post, inverse_of: :images
		mount_uploader :image, ImageUploader

		validates_presence_of :post, :image
	end
end
