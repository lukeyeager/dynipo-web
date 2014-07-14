class Server < ActiveRecord::Base
    validates :name, presence: true
    validates :admin_password, presence: true

    has_many :updates

    def recent_ip
        u = updates.sort_by{|u| u.created_at}.last || nil
        return nil if u.nil?
        return u.ip_address
    end
end
