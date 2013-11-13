class Events < ActiveRecord::Migration
  def up
    create_table :events do |t|
      t.string :event_text
      t.string :source
      t.datetime :timestamp
    end
  end

  def down
    drop_table :events
  end
end
