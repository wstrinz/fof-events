require 'sinatra/base'
require 'sinatra/activerecord'

class EventDump < ActiveRecord::Base
end

class Event < ActiveRecord::Base
end

class EventRecorder
  def self.record(msg, id, buffer=nil)

    parse(msg) do |event|
      store(event, id, buffer)
    end

    d = EventDump.new
    d.received = Time.new
    d.save
  end

  def self.parse(event)
    # Use ID here
    event.split("\n").each do |e|
      yield e
    end
  end

  def self.store(event, id, buffer = nil)
    if buffer
      buffer << event
    else
      puts event
      e = Event.new()
      e.event_text = event
      e.timestamp = Time.now
      e.source = id.to_s
      e.save
    end
  end
end

class EventServer < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  helpers do
    def record(events, id)
      EventRecorder.record(events, id)
    end
  end

  configure do
    set :database, "sqlite3:///db/database.sqlite3"
  end

  get '/' do
    "its working"
  end

  get '/testpost' do
    str = <<-EOS
    {"event":"createRoom","clientID":"-1","result":true}
    {"event":"togglePause","state":false,"clientID":"gen_kr0eqo_823"}
    {"event":"joinRoom","clientID":"1","result":true,"roomName":"gen_kr0eqo_823","userName":"Farmer krmhp0"}
    EOS
    record(str, "test_id_123")
  end

  get '/events' do
    Event.all.map(&:event_text).join("<br>")
  end

  get '/event_dumps' do
    EventDump.all.map(&:received).join("<br>")
  end

  post '/record/:id' do
    record(request.body.read, params[:id])
  end

  get '/new_id' do
    "#{Time.now.nsec.to_s(32)}#{rand(1000)}"
  end

  run! if app_file == $0
end
