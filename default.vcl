vcl 4.0;

backend server1 {
    .host = "daemon";
    .port = "10211";
}

import std;
import directors;
import saintmode;
import bodyaccess;

sub vcl_init {
  new cluster_daemon = directors.round_robin();
  cluster_daemon.add_backend(server1);
}

acl purge {
    "localhost";
}

sub vcl_recv {
  if (req.method == "PURGE") {
    if (!client.ip ~ purge) {
        return(synth(405, "Not allowed."));
    }
    return (purge);
  }

  set req.backend_hint = cluster_daemon.backend();
}

sub vcl_recv {
    unset req.http.cookie;
    unset req.http.X-Body-Len;
    
    std.cache_req_body(500KB);
    bodyaccess.log_req_body("PREFIX:", 40);

    if (bodyaccess.rematch_req_body("masternodelist") == 1) {
        std.log("caching masternodelist for 1 min");
        set req.http.X-Cacheable = 1;
    }

    return (hash);
}

sub vcl_hash {
    bodyaccess.hash_req_body();
}

sub vcl_backend_fetch {
    set bereq.method = "POST";
    set bereq.http.Authorization = "Basic cmFuZG9tcnBjdXNlcjIzOTQ4OnJwY3JhbmRvbXBhc3N3b3JkOTg0NTc0MzluOHY=";
}

sub vcl_backend_response {
    if (bereq.http.X-Cacheable ~ "^1$") {
        set beresp.ttl = 60s;
    } else {
        set beresp.uncacheable = true;
    }
    return (deliver);
}

sub vcl_deliver {
    unset resp.http.X-Cacheable;
    unset resp.http.Via;
    unset resp.http.X-Varnish;
}
