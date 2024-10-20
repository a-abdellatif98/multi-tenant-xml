class TenantsController < ApplicationController
  def index
    render plain: 'Tenant loaded successfully.'
  end
end
