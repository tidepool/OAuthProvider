# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invitation do
    email_invite_list {{ 
      'foo@kk.com' => 'sent',
      'bar@kk.com' => 'not_sent'
    }}
  end
end
