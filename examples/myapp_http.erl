-module(myapp_http).
-export([childspec/0]).

childspec() ->
  HTTPDispatch = cowboy_router:compile(
                   [
                    {'_', [
                           {"/api/ws", myapp_ws_handler, []},
                           {"/api/[...]", apixiom, {myapp_httpapi, #{}}},
                           {"/[...]", cowboy_static,
                            {dir, "public",
                             [
                              {mimetypes, cow_mimetypes, all},
                              {dir_handler, directory_handler}
                             ]
                            }
                           }
                          ]}
                   ]),
  HTTPOpts=[{connection_type, supervisor},
            {port,
             application:get_env(myapp, rpcport, 33080)
            }],
  HTTPConnType=#{connection_type => supervisor,
                 env => #{dispatch => HTTPDispatch}},
  HTTPAcceptors=10,
  [
   ranch:child_spec(http,
                    HTTPAcceptors,
                    ranch_tcp,
                    HTTPOpts,
                    cowboy_clear,
                    HTTPConnType),
   ranch:child_spec(http6,
                    HTTPAcceptors,
                    ranch_tcp,
                    [inet6, {ipv6_v6only, true}|HTTPOpts],
                    cowboy_clear,
                    HTTPConnType)
  ].



