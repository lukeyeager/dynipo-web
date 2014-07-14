json.array!(@servers) do |server|
  json.extract! server, :id, :name, :description, :password, :admin_password
  json.url server_url(server, format: :json)
end
