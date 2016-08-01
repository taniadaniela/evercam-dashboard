class Licence < Sequel::Model
  # Payment Method types.
  STRIPE = 0
  CUSTOM = 1
  OTHER  = 2
  many_to_one :user, class: 'User', key: :user_id
end
