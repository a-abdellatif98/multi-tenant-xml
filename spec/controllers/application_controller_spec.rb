require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'Tenant loaded'
    end
  end

  before do
    Rails.cache.clear # Clear Redis cache
    allow(File).to receive(:read).and_return('<tenant></tenant>') # Stub XML loading
  end

  it 'loads the correct tenant configuration based on subdomain' do
    request.host = 'tenant_a.example.com'
    expect_any_instance_of(TenantLoader).to receive(:load_models)
    get :index
    expect(response.body).to eq('Tenant loaded')
  end

  it 'caches tenant configuration to avoid reloading on every request' do
    request.host = 'tenant_a.example.com'
    tenant_name = 'tenant_a'
    key = "tenant_#{tenant_name}_config"

    # First request: load and cache XML content
    get :index
    expect(Rails.cache.read(key)).to_not be_nil

    # Second request: Ensure cache is used, not file reading
    expect(File).not_to receive(:read)
    get :index
  end
end
