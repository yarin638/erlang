%%%-------------------------------------------------------------------
%%% @author yarinabutbul
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. Jul 2021 16:51
%%%-------------------------------------------------------------------
-module(traffic_light).
-author("yarinabutbul").
-behaviour(gen_statem).
-define(NAME, traffic_light).
%% API
-export([start_link/0]).
-export([init/1,callback_mode/0]).
-export([timeout/0]).
-export([red/3,yellow/3,green/3]).


start_link() ->
  gen_statem:start_link({local, ?NAME}, ?MODULE, [], []).

callback_mode() -> state_functions.

init([]) ->
{ok, red}.


%events
timeout()-> gen_statem:cast(?NAME, {time}).

%states
red({call, yellow}, EventContent, StateData)-> io:format("red~n"),{next_state,yellow, red}.

yellow({call, red}, EventContent, StateData)-> io:format("yellow~n"),{next_state,yellow, green};
yellow({call, green}, EventContent, StateData)-> io:format("yellow~n"),{next_state,yellow, red}.

green({call, yellow}, EventContent, StateData)-> io:format("yellow~n"),{next_state,green, yellow}.
