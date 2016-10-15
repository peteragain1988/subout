class VehicleObserver < Mongoid::Observer
  observe :vehicle

  def after_create(vehicle)
    Notifier.delay_for(1.minutes).new_vehicle(vehicle.id)
  end

  def after_destroy(vehicle)
    Notifier.delay.remove_vehicle(vehicle)
  end
end
