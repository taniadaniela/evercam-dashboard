class VendorModel < Sequel::Model
  many_to_one :vendor
  one_to_many :cameras
  DEFAULT = 'Default'
  # Returns a deep merge of any config values set for this
  # model with the default vendor config
  def config
    if DEFAULT != name
      default = vendor.default_model ? vendor.default_model.config : {}
      default.deep_merge(values[:config])
    else
      values[:config] || {}
    end
  end
end
