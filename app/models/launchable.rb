class Launchable
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ProviderModel
  extend ActiveModel::Naming

  attr_accessor :id, :name, :description, :wm_state

  WM_STATE_ACTIVE = "ACTIVE"
  WM_STATE_INACTIVE = "INACTIVE"

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
