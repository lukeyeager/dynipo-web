class Update < ActiveRecord::Base
	include ActionView::Helpers::TextHelper

	belongs_to :server

	validates :ip_address, format: {
			with: /(?:\d{1,3}\.){3}\d{1,3}/,
			message: 'not a valid IP address' }

	def duration
		mins = ((updated_at - created_at)/60).round
		hours = mins / 60
		days = hours / 24

		if days > 0
			"#{pluralize days, 'day'} and #{pluralize (hours % 24), 'hour'}"
		elsif hours > 0
			"#{pluralize hours, 'hour'} and #{pluralize (mins % 60), 'minute'} minutes"
		elsif mins > 0
			pluralize mins, 'minute'
		else
			'1 minute'
		end
	end
end
