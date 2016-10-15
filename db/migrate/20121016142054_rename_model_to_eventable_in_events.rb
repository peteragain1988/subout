class RenameModelToEventableInEvents < Mongoid::Migration
  def self.up
    Event.all.each do |e|
      e.model_type = e.model_type.try(:capitalize)
      e.save

      e.rename(:model_id, :eventable_id)
      e.rename(:model_type, :eventable_type)
    end
  end

  def self.down
    Event.all.each do |e|
      e.rename(:eventable_id, :model_id)
      e.rename(:eventable_type ,:model_type)
    end
  end
end
