import vibe.d;

shared static this()
{
  auto router = new URLRouter;
  
  // following routes can be accessed without authentication
  router.get("/", &index);
  
  // any other request will be matched and checked for authentication
  router.any("*", performBasicAuth("Site Realm", toDelegate(&checkPassword)));
  
  // any following routes can only be accessed when authenticated
  
	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
  
	listenHTTP(settings, router);

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
}

void index(HTTPServerRequest req, HTTPServerResponse res)
{
  res.render!("index.dt", req);
}

bool checkPassword(string user, string password)
{
  return user == "admin" && password == "admin";
}
