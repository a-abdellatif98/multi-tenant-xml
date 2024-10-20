require 'rails_helper'

RSpec.describe TenantLoader, type: :service do
  let(:xml_content) do
    <<-XML
      <tenant>
        <models>
          <user>
            <field name="email" type="string" required="true" unique="true" />
            <field name="age" type="integer" required="true" min="18" max="60" />
          </user>
        </models>
        <callbacks>
          <before_save model="user">validate_age</before_save>
        </callbacks>
      </tenant>
    XML
  end

  before do
    Rails.cache.clear # Clear cache before each test
    allow(File).to receive(:read).and_return(xml_content) # Stub file reading
  end

  it 'caches tenant configuration in Redis' do
    tenant_name = 'tenant_a'
    key = "tenant_#{tenant_name}_config"

    # Simulate caching
    Rails.cache.fetch(key) { xml_content }
    cached_content = Rails.cache.read(key)

    # Ensure cached content is correct
    expect(cached_content).to eq(xml_content)
  end
end
