class ServersController < ApplicationController

	# /
	def home
	end

	# /servers
	def index
		@servers = Server.order(:name)
	end

	# /servers/1
	# /server/name
	# /server/name.json
	def show
		unless set_server
			respond_to do |format|
				format.html {redirect_to root_url, :flash => {:error => 'Server not found' } }
				format.json {render json: 'Server not found', status: :not_found}
			end
			return
		end
		unless require_password
			respond_to do |format|
				format.html {redirect_to root_url, :flash => {:error => 'Incorrect server/password combination'} }
				format.json {render json: 'Wrong password', status: :not_authorized}
			end
			return
		end
		respond_to do |format|
			format.html {render}
			format.json {render json: {name: @server.name, description: @server.description, ip: @server.recent_ip} }
		end
	end

	# /update.json
	def update_ip
		unless set_server
			render json: {error: 'Server not found'}, status: :not_found
			return
		end
		unless require_admin_password
			render json: {error: 'Incorrect server/password combination'}, status: :forbidden
			return
		end

		ip = request.remote_ip
		ip = '127.0.0.1' if ip == '::1' #Don't allow IPv6 formatted localhost

		if last_update = @server.last_update
			if last_update.ip_address == ip
				# Previous IP is the same
				last_update.touch
				u = last_update
			else
				# Previous IP doesn't match
				u = @server.updates.build(:ip_address => ip)
			end
		else
			# First IP update
			u = @server.updates.build(:ip_address => ip)
		end

		if u.save
			render json: 'IP Address updated'
		else
			render json: {error: 'Update could not be saved'}, status: :bad_request
		end
		return
	end

	# GET /servers/new
	def new
		@server = Server.new
	end

	# POST /servers
	def create
		@server = Server.new(server_params)

		if @server.save
			redirect_to "/server/#{@server.name}?password=#{@server.password}", notice: 'Server was successfully created.'
		else
			render :new
		end
	end

	# GET /servers/1/edit
	def edit
		unless set_server
			redirect_to :index, :flash => {:error => 'Server not found.'}
		end
		@authorized = require_admin_password
	end

	# PATCH/PUT /servers/1
	def update
		unless set_server
			redirect_to action: :index, :flash => {:error => 'Server not found.'}
			return
		end
		unless require_admin_password
			redirect_to action: :index, :flash => {:error => 'Password required.'}
			return
		end
		if @server.update(server_params)
			redirect_to "/server/#{@server.name}?password=#{@server.password}", notice: 'Server was successfully updated.'
			return
		else
			render :edit
		end
	end

	# DELETE /servers/1
	def destroy
		unless set_server
			redirect_to action: :index, :flash => {:error => 'Server not found.'}
			return
		end
		unless require_admin_password
			render
			return
		end
		@server.destroy
		redirect_to servers_url, notice: 'Server was successfully destroyed.'
	end

	private
		def set_server
			@server = Server.find_by_id(params[:id]) if params[:id] and !params[:id].blank?
			@server = Server.find_by_name(params[:name]) if @server.nil? and params[:name] and !params[:name].blank?
			return !@server.nil?
		end

		# Require password = server.password
		def require_password
			return (params[:password] and params[:password] == @server.password)
		end

		# Require password = server.admin_password
		def require_admin_password
			return (params[:password] and params[:password] == @server.admin_password)
		end

		# Never trust parameters from the scary internet, only allow the white list through.
		def server_params
			params.require(:server).permit(:name, :description, :password, :admin_password)
		end
end
