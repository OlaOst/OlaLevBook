import vibe.d;

shared static this()
{
  auto router = new URLRouter;
  
  // following routes can be accessed without authentication
  router.get("/", staticTemplate!"index.dt");
  router.post("/login", &login);
  router.post("/logout", &logout);
  
  // any following routes can only be accessed when authenticated
  router.any("*", &checkLogin);
  router.get("/home", staticTemplate!"home.dt");
  
	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
  settings.sessionStore = new MemorySessionStore;
  
	listenHTTP(settings, router);

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
}

void checkLogin(HTTPServerRequest req, HTTPServerResponse res)
{
  // force redirect to / for unauthenticated users
  if (!req.session)
    res.redirect("/");
}

void logout(HTTPServerRequest req, HTTPServerResponse res)
{
  if (req.session)
    res.terminateSession();
    
  res.redirect("/");
}

void login(HTTPServerRequest req, HTTPServerResponse res)
{
  enforceHTTP("username" in req.form && "password" in req.form, HTTPStatus.badRequest, "Missing username/password field");
  
  // TODO: verify username/password
  
  import std.stdio;
  writeln("username ", req.form["username"], ", password ", req.form["password"]);
  
  if (validLogin(req.form["username"], req.form["password"]))
  {
    auto session = res.startSession();
    session.set("username", req.form["username"]);
    session.set("password", req.form["password"]);
    res.redirect("/home");
  }
  else
  {
    res.redirect("/logout");
  }
}

bool validLogin(string username, string password)
{
  auto users = ["admin" : "admin"];
  
  auto passCheck = (username in users);

  return (passCheck !is null) && (*passCheck) == password;
}
