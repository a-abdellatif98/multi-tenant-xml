class ApplicationController < ActionController::Base
  before_action :load_current_tenant

  private

  def load_current_tenant
    # Use request parameters and provide clear logging
    tenant_name = params[:tenant] || request.subdomain || 'default_tenant'

    Rails.logger.info "Resolved tenant name: #{tenant_name}"

    if tenant_name.blank?
      Rails.logger.error 'Tenant name is missing. Cannot load tenant configuration.'
      render plain: 'Tenant not found', status: :bad_request and return
    end

    key = "tenant_#{tenant_name}_config"

    # Attempt to fetch the configuration from Redis
    xml_content = Rails.cache.fetch(key, expires_in: 1.hour) do
      Rails.logger.info "Cache miss for #{key}. Loading from file."

      file_path = Rails.root.join('config', 'tenants', "#{tenant_name}.xml")

      # Check if the file exists
      unless File.exist?(file_path)
        Rails.logger.error "Tenant configuration file not found: #{file_path}"
        render plain: 'Tenant configuration file not found', status: :not_found and return
      end

      File.read(file_path) # Load XML content from the file
    end

    # Initialize the TenantLoader with the loaded XML content
    TenantLoader.new(xml_content).load_models
    Rails.logger.info "Tenant models loaded for #{tenant_name}."
  end
end
