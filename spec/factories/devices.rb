# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :device do
    sequence(:name) {|n| "My Device ##{n}" }
    sequence(:os_version) {|n| "6.#{n}" }
    sequence(:hardware) {|n| "Hardware ##{n}" }
    sequence(:token) {|n| "TOKEN#{n*1234}"}
  end
end
