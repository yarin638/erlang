%%%-------------------------------------------------------------------
%%% @author eliav
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. אוג׳ 2021 16:43
%%%-------------------------------------------------------------------
-module('Cars').
-author("eliav").

-behaviour(gen_statem).

-define(SERVER, ?MODULE).
%% API
%%gen_state functions%%
-export([start_link/0,start/3,init/1]).
%%States%%
%-export([]).
%%Events%%
%-export([]).

start_link() ->
  gen_statem:start_link({local, ?SERVER}, ?MODULE, [], []).

start(Cnum,Details,PC)->
  gen_statem:start({local,Cnum},?MODULE,[Cnum,Details,PC],[]).

init([Cnum,Details,PC])->
  put(cnum,Cnum),
  put(details,Details),
  ets:insert(car,{Cnum,Details,PC,self()}),
  {ok,}

