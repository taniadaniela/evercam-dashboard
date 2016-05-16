Airbrake.configure do |config|
  config.project_id = "#{ENV['AIRBRAKE_PROJECT_ID']}"
  config.project_key = "#{ENV['AIRBRAKE_PROJECT_KEY']}"
  config.ignore_environments = %w(development)
end

Airbrake.add_filter do |notice|
  if notice[:errors].any? { |error| error[:type] == 'Evercam::CameraOfflineError' }
    notice.ignore!
  end

  if notice[:errors].any? { |error| error[:type] == 'Evercam::NotFoundError' }
    notice.ignore!
  end

  if notice[:errors].any? { |error| error[:type] == 'Evercam::EvercamError' }
    notice.ignore!
  end

end
