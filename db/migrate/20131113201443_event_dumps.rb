class EventDumps < ActiveRecord::Migration
  def up
    create_table :event_dumps do |t|
      t.datetime :received
    end
  end

  def down
    drop_table :event_dumps
  end
end
