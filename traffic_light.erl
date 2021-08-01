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

-export([start/0,push/0,get_count/0,stop/0]).
-export([terminate/3,code_change/4,init/1,callback_mode/0]).
-export([green/3,red/3,yellow/3]).

name() -> pushbutton_statem. % The registered server name

%% API.  This example uses a registered name name()
%% and does not link to the caller.
start() ->
  gen_statem:start({local,name()}, ?MODULE, [], []).
push() ->
  gen_statem:call(name(), push).
get_count() ->
  gen_statem:call(name(), get_count).
stop() ->
  gen_statem:stop(name()).

%% Mandatory callback functions
terminate(_Reason, _State, _Data) ->
  void.
code_change(_Vsn, State, Data, _Extra) ->
  {ok,State,Data}.
init([]) ->
  %% Set the initial state + data.  Data is used only as a counter.
  State = red, Data = 0,
  {ok,State,Data}.
callback_mode() -> state_functions.

%%% state callback(s)

red({call,From}, push, Data) ->
  %% Go to 'on', increment count and reply
  %% that the resulting status is 'on'
  {next_state,yellow,Data+1,[{reply,From,yellow}]};
red(EventType, EventContent, Data) ->
  handle_event(EventType, EventContent, Data).


yellow({call,From}, push, Data) ->
  %% Go to 'on', increment count and reply
  %% that the resulting status is 'on'
  {next_state,green,Data+1,[{reply,From,green}]};
yellow(EventType, EventContent, Data) ->
  handle_event(EventType, EventContent, Data).

green({call,From}, push, Data) ->
  %% Go to 'off' and reply that the resulting status is 'off'
  {next_state,red,Data,[{reply,From,red}]};
green(EventType, EventContent, Data) ->
  handle_event(EventType, EventContent, Data).

%% Handle events common to all states
handle_event({call,From}, get_count, Data) ->
  %% Reply with the current count
  {keep_state,Data,[{reply,From,Data}]};
handle_event(_, _, Data) ->
  %% Ignore all other events
  {keep_state,Data}.