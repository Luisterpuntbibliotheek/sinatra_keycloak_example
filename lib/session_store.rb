require 'json'
require_relative 'session'

class SessionStore
  include Enumerable
  attr_reader :app

  def initialize(session_dir = './sessions', app = nil)
    @sessions_dir = session_dir
    @app = app

    pp @app
  end

  def each
    all_sessions.each do |file|
      yield load_session(file)
    end
  end

  def [](id)
    load_session(id)
  end

  def []=(id, session)
    save_session(id, session)
  end

  private

  def session_name(id)
    "#{@sessions_dir}/#{id}"
  end

  def load_session(id)
    Session.new(JSON.parse(File.read(session_name(id))), id)
  rescue StandardError => e
    Session.new
  end

  def save_session(id, session)
    File.open(session_name(id), "wb") do |f|
      f.write session.to_json
    end
  end

  def delete_session(id)
    File.delete(session_name(id))
  end

  def all_sessions
    Dir.entries(@sessions_dir).select { |s| s =~ /\.json$/ }
  end
end