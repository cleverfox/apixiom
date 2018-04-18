-module(myapp_httpapi).

-export([h/3, after_filter/1]).

after_filter(Req) ->
  Origin=cowboy_req:header(<<"origin">>, Req, <<"*">>),
  Req1=cowboy_req:set_resp_header(<<"access-control-allow-origin">>,
                                  Origin, Req),
  Req2=cowboy_req:set_resp_header(<<"access-control-allow-methods">>,
                                  <<"GET, POST, OPTIONS">>, Req1),
  Req3=cowboy_req:set_resp_header(<<"access-control-allow-credentials">>,
                                  <<"true">>, Req2),
  Req4=cowboy_req:set_resp_header(<<"access-control-max-age">>,
                                  <<"86400">>, Req3),
  cowboy_req:set_resp_header(<<"access-control-allow-headers">>,
                             <<"content-type">>, Req4).

h(Method, [<<"api">>|Path], Req) ->
  lager:info("Path ~p", [Path]),
  h(Method, Path, Req);

h(<<"GET">>, [<<"node">>, <<"status">>], Req) ->
  QS=cowboy_req:parse_qs(Req),
  BinPacker=case proplists:get_value(<<"bin">>, QS) of
              <<"b64">> -> fun(Bin) -> base64:encode(Bin) end;
              <<"hex">> -> fun(Bin) -> bin2hex:dbin2hex(Bin) end;
              <<"raw">> -> fun(Bin) -> Bin end;
              _ -> fun(Bin) -> base64:encode(Bin) end
            end,
  {200,
   #{ result => <<"ok">>,
      status => #{
        nodeid=>nodekey:node_id(),
        public_key=>BinPacker(<<1,2,3,4,5,6,7,8>>)
       }
    }};


h(<<"POST">>, [<<"test">>, <<"request_fund">>], Req) ->
  Body=apixiom:bodyjs(Req),
  lager:info("B ~p", [Body]),
  {200,
   #{ result => <<"ok">> }
  };

h(<<"OPTIONS">>, _, _Req) ->
  {200, [], ""};

h(_Method, [<<"status">>], Req) ->
  {RemoteIP, _Port}=cowboy_req:peer(Req),
  lager:info("Join from ~p", [inet:ntoa(RemoteIP)]),
  %Body=apixiom:bodyjs(Req),

  {200,
   #{ result => <<"ok">>,
      client => list_to_binary(inet:ntoa(RemoteIP))
    }
  }.

