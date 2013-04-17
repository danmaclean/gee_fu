class AnnojParamSanitiser
  def initialize(app)
    @app = app
  end

  def call(env)
    sanitise_params(env)
    @app.call(env)
  end

  def sanitise_params(env)
    req = Rack::Request.new(env)
    (req.post? ? req.POST : req.GET)[:annoj_action] = req.params["action"] if req.params.has_key?("action")
    @params = nil
  end
end