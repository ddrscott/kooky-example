class KookyHandler
  def initialize(app)
    @app = app
  end

  def call(env)
    # for hot reloading, otherwise everything could be in handler.
    load 'app/models/kooky_caller.rb'
    KookyCaller.new.call(@app, env)  
  end
end
