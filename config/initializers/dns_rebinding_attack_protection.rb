Rails.application.config.hosts << "www.example.com" if Rails.env.test?

return unless Rails.env.production?

Rails.application.configure do
  if ENV["RAILS_DNS_REBINDING_ATTACK_PROTECTION_ALLOW_IP_1"].present?
    config.hosts << IPAddr.new(ENV["RAILS_DNS_REBINDING_ATTACK_PROTECTION_ALLOW_IP_1"])
  end
  if ENV["RAILS_DNS_REBINDING_ATTACK_PROTECTION_ALLOW_IP_2"].present?
    config.hosts << IPAddr.new(ENV["RAILS_DNS_REBINDING_ATTACK_PROTECTION_ALLOW_IP_2"])
  end
  if ENV["RAILS_DNS_REBINDING_ATTACK_PROTECTION_ALLOW_DOMAIN_1"].present?
    config.hosts << ENV["RAILS_DNS_REBINDING_ATTACK_PROTECTION_ALLOW_DOMAIN_1"]
  end
  if ENV["RAILS_DNS_REBINDING_ATTACK_PROTECTION_ALLOW_DOMAIN_2"].present?
    config.hosts << ENV["RAILS_DNS_REBINDING_ATTACK_PROTECTION_ALLOW_DOMAIN_2"]
  end
end

# DNS rebinding attack ref.
# https://github.com/rails/rails/pull/33145
# https://guides.rubyonrails.org/configuring.html#actiondispatch-hostauthorization
