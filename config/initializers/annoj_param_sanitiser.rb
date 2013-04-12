class AnnojParamSanitiser
  def initialize(app)
    @app = app
  end

  def call(env)
    sanitise_params(env)
    @app.call(env)
  end

  def sanitise_params(env)
    return if env["rack.request.form_hash"].nil?
    req = Rack::Request.new(env)
    req.POST[:annoj_action] = env["rack.request.form_hash"]["action"]
    @params = nil
  end
end