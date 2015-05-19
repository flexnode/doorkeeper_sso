Fabricator(:api_application) do
  name { FFaker::Internet.domain_word }
  api_key { FFaker::Lorem.characters(16) }
end

# == Schema Information
# Schema version: 20150320075507
#
# Table name: api_applications
#
#  id         :integer          not null, primary key
#  name       :string
#  api_key    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
