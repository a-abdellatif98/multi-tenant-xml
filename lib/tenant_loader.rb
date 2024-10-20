require 'nokogiri'

class TenantLoader
  def initialize(xml_content)
    @xml_doc = Nokogiri::XML(xml_content)
  end

  def load_models
    @xml_doc.xpath('//models/*').each do |model_node|
      generate_model(model_node)
    end
  end

  private

  def generate_model(model_node)
    model_name = model_node.name.capitalize
    klass = Object.const_set(model_name, Class.new(ActiveRecord::Base))
    klass.table_name = model_node.name.pluralize

    # Define fields and validations
    model_node.xpath('field').each do |field_node|
      field_name = field_node['name'].to_sym
      field_type = field_node['type'].to_sym
      klass.send(:attribute, field_name, field_type)

      klass.validates field_name, presence: true if field_node['required'] == 'true'
      klass.validates field_name, uniqueness: true if field_node['unique'] == 'true'
    end

    apply_callbacks(klass, model_node)
  end

  def apply_callbacks(klass, model_node)
    model_node.xpath('../callbacks/*').each do |callback_node|
      callback_type = callback_node.name.to_sym
      method_name = callback_node.text.to_sym

      klass.send(callback_type, method_name) if klass.method_defined?(method_name)
    end
  end
end
