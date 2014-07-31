class Server < ActiveRecord::Base
    validates :name, presence: true, uniqueness: true
    validates :admin_password, presence: true

    has_many :updates

    def last_update
        updates.sort_by{|u| u.created_at}.last || nil
    end
end
