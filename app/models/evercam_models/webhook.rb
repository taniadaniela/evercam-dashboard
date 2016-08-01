class Webhook < Sequel::Model
  many_to_one :camera, class: 'Camera'
  many_to_one :user, class: 'User'
end
