class Update < ActiveRecord::Base
    belongs_to :server

    validates :ip_address, format: {
            with:  /(?:\d{1,3}\.){3}\d{1,3}/,
            message: 'not a valid IP address' }
end
