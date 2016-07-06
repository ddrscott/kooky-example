class KookyCaller
  def call(app, env)
    # check if cookie exists
    req = Rack::Request.new(env)
    
    status, headers, body = app.call(env)

    # Only add cookie the first time
    if req.cookies['from_rack'].nil?
      Rack::Utils.set_cookie_header!(headers, "from_rack", {:value => Time.current.to_s, :path => "/"})
    end

    dispatch_cookies = env['action_dispatch.cookies']

    # Hijack response body to add debug output
    body = [body.to_a.join("\n").sub('</body>', <<-HTML)]
    <h1>Rack Output</h1>
    request.cookies: #{req.cookies['from_rails']}<br/>
    action_dispatch.cookies: #{dispatch_cookies['from_rails']}<br/>
    any_cookie[from_rails]: #{rails_or_rake_cookie(env, 'from_rails')}<br/>
    any_cookie[from_rack]: #{rails_or_rake_cookie(env, 'from_rack')}
    </body>
HTML
    [status, headers, body]
  end

  # Rails sets its cookies through ActionDispath. This makes it "hard" to get at
  # them through standard Rack tooling. This method hellps get the cookie
  # information from either source, prioritizing Rails over Rack.
  def rails_or_rake_cookie(env, key)
    env['action_dispatch.cookies'].try(:[], key) || Rack::Request.new(env).cookies[key]
  end
end
