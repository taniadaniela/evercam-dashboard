class MotionDetection < Sequel::Model
  many_to_one :camera
  def validate
    super
    errors.add(:camera_id, 'has not been set') if !camera_id
  end
end
