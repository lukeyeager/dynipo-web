class ServersController < ApplicationController
  before_action :set_server, only: [:show, :edit, :update, :destroy]
  before_action :require_password, only: [:show]
  before_action :require_admin_password, only: [:edit, :update, :destroy]

	# /
	def home
		@server = Server.new
	end

  # /servers
  def index
		@servers = Server.all
  end

  # /servers/1
	# /server/name
  def show
		unless @server
			respond_to do |format|
				format.html {redirect_to root_url, error: 'Server not found'}
				format.json {render json: 'Server not found', status: :not_found}
			end
			return
		end
  end

	# /update
	def update_ip
	end

  # GET /servers/new
  def new
    @server = Server.new
  end

  # GET /servers/1/edit
  def edit
  end

  # POST /servers
  # POST /servers.json
  def create
    @server = Server.new(server_params)

    respond_to do |format|
      if @server.save
        format.html { redirect_to @server, notice: 'Server was successfully created.' }
        format.json { render :show, status: :created, location: @server }
      else
        format.html { render :new }
        format.json { render json: @server.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /servers/1
  # PATCH/PUT /servers/1.json
  def update
    respond_to do |format|
      if @server.update(server_params)
        format.html { redirect_to @server, notice: 'Server was successfully updated.' }
        format.json { render :show, status: :ok, location: @server }
      else
        format.html { render :edit }
        format.json { render json: @server.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /servers/1
  # DELETE /servers/1.json
  def destroy
    @server.destroy
    respond_to do |format|
      format.html { redirect_to servers_url, notice: 'Server was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_server
			@server = Server.find_by_id(params[:id]) if params[:id] and !params[:id].blank?
			@server = Server.find_by_name(params[:name]) if @server.nil? and params[:name] and !params[:name].blank?
    end

		# Require password = server.password
    def require_password
			@authorized = params[:password] and params[:password] == @server.password
		end

		# Require password = server.admin_password
    def require_admin_password
			@authorized = params[:password] and params[:password] == @server.admin_password
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def server_params
      params.require(:server).permit(:name, :description, :password, :admin_password)
    end
end
