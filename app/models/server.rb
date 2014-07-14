class Server < ActiveRecord::Base
    validates :name, presence: true
    validates :admin_password, presence: true

    has_many :updates
end
