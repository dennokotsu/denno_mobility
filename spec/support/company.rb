RSpec.configure do |_config|
  # Company#setting_data の user_attribute のうち require: true になっている全ての default を得る
  # 特定の Company インスタンスを渡すとその setting_data を利用する
  # company を指定しない (nil を渡す) と Company.example_setting_data を利用する
  # HTTP request の params を作る際にご利用下さい
  #
  # @param [Company, nil] company
  # @return [Hash{Symbol => Integer, Float, String, Array<String>}]
  def company_setting_data_user_attribute_required_defaults(company = nil)
    setting_data = company&.setting_data || Company.example_setting_data
    setting_data["user_attribute"].filter { _1["require"] }.map do
      [_1["name"].to_sym, _1["default"]]
    end.to_h
  end

  # Company#setting_data の slip_attribute のうち require: true になっている全ての default を得る
  # 特定の Company インスタンスを渡すとその setting_data を利用する
  # company を指定しない (nil を渡す) と Company.example_setting_data を利用する
  # HTTP request の params を作る際にご利用下さい
  #
  # @param [Company, nil] company
  # @return [Hash{Symbol => Integer, Float, String, Array<String>}]
  def company_setting_data_slip_attribute_required_defaults(company = nil)
    setting_data = company&.setting_data || Company.example_setting_data
    setting_data["slip_attribute"].filter { _1["require"] }.map do
      [_1["name"].to_sym, _1["default"]]
    end.to_h
  end
end
