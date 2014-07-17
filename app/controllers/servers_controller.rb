class ServersController < ApplicationController

	# /
	def home
	end

	# /servers
	def index
		@servers = Server.all
	end

	# /servers/1
	# /server/name
	# /server/name.json
	def show
		unless set_server
			respond_to do |format|
				format.html {redirect_to root_url, :flash => { :error => 'Server not found' } }
				format.json {render json: 'Server not found', status: :not_found}
			end
			return
		end
		@authorized = require_password
	end

	# /update.json
	def update_ip
		unless set_server
			render json: {error: 'Server not found'}, status: :not_found
			return
		end
		unless require_admin_password
			render json: {error: 'Incorrect server/password combination'}, status: :not_authorized
			return
		end

		u = @server.updates.build(:ip_address => request.remote_ip)
		if u.save
			render json: 'succeeded'
		else
			render json: @server.errors, status: :bad_request
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
			redirect_to :index, error: 'Server not found.'
		end
		@authorized = require_admin_password
	end

	# PATCH/PUT /servers/1
	def update
		unless set_server
			redirect_to :index, error: 'Server not found.'
		end
		unless require_admin_password
			redirect_to :index, error: 'Password required.'
		end
		if @server.update(server_params)
			redirect_to @server, notice: 'Server was successfully updated.'
		else
			render :edit
		end
	end

	# DELETE /servers/1
	def destroy
		unless set_server
			redirect_to action: :index, :flash => {error: 'Server not found.'}
		end
		unless require_admin_password
			redirect_to action: :index, :flash => {error: 'Password required.'}
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
