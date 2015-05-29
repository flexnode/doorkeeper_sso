Fabricator(:user) do
  first_name { FFaker::Name.name }
  last_name { FFaker::Name.last_name }
  name { |attrs| [attrs[:first_name], attrs[:last_name]].join(" ") }
  email { FFaker::Internet.email }
  password { FFaker::Internet.password }
  password_confirmation { |attrs| "#{attrs[:password]}" }
end

# == Schema Information
# Schema version: 20150320075507
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default("0"), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string
#  last_name              :string
#  lang                   :string           default("EN")
#  phone                  :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
