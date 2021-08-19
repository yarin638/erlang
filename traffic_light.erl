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

-export([start/2,push/1,timeout/0,stop/0]).
-export([terminate/3,code_change/4,init/1,callback_mode/0]).
-export([green/3,red/3,yellowFormRed/3,yellowFormGreen/3]).

name() -> pushbutton_statem. % The registered server name

%% API.  This example uses a registered name name()
%% and does not link to the caller.
start({R,X,Y,Color},Name) ->% insert junction to ets and go to red

  gen_statem:start({local,Name}, ?MODULE, [{R,X,Y,Color}], []).
push(Name) ->
  gen_statem:call(Name, push).

timeout()-> gen_statem:call(name(),{time}). % timeout event

stop() ->
  gen_statem:stop(name()).

%% Mandatory callback functions
terminate(_Reason, _State, _Data) ->
  void.
code_change(_Vsn, State, Data, _Extra) ->
  {ok,State,Data}.
init([{R,X,Y,Color}]) ->
  %% Set the initial state + data.  Data is used only as a counter.
  State = Color, Data = 0,
  ets:insert(traffic_light,{R,{X,Y},self()}),
  {ok,State,Data,6000}.
callback_mode() -> state_functions.

%%% state callback(s)

%red({call,From}, push, Data) ->
  %% Go to 'on', increment count and reply
  %% that the resulting status is 'on'
 % io:format("yellow~n"),
  %{next_state,yellow,Data+1,[{state_timeout,3000,lock}]};

red(timeout, 6000,  Data) ->
 %io:format("yellow~n"),
  {next_state, yellowFormRed, Data, [{timeout,6000,lock}]};

red(timeout, lock,  Data) ->
  %io:format("yellow~n"),
  {next_state, yellowFormRed, Data,[{timeout,6000,lock}]};


red(EventType, EventContent, Data) ->
  handle_event(EventType, EventContent, Data).


yellowFormRed(timeout, 6000,  Data) ->
  %% Go to 'on', increment count and reply
  %% that the resulting status is 'on'
  {next_state,green,Data+1,[{timeout,6000,lock}]};

yellowFormRed(timeout, lock,  Data) ->
  %io:format("green~n"),
  {next_state, green, Data,[{timeout,6000,lock}]};

yellowFormRed(EventType, EventContent, Data) ->
  handle_event(EventType, EventContent, Data).


yellowFormGreen(timeout, 6000,  Data) ->
  %% Go to 'on', increment count and reply
  %% that the resulting status is 'on'
  {next_state,red,Data+1,[{timeout,6000,lock}]};

yellowFormGreen(timeout, lock,  Data) ->
  %io:format("red~n"),
  {next_state, red, Data,[{timeout,6000,lock}]};

yellowFormGreen(EventType, EventContent, Data) ->
  handle_event(EventType, EventContent, Data).

green(timeout, 6000,  Data) ->
  %% Go to 'off' and reply that the resulting status is 'off'
  {next_state,yellowFormGreen,Data,[{timeout,6000,lock}]};

green(timeout, lock,  Data) ->
  %io:format("yekkow~n"),
  {next_state, yellowFormGreen, Data,[{timeout,6000,lock}]};

green(EventType, EventContent, Data) ->
  handle_event(EventType, EventContent, Data).

%% Handle events common to all states
handle_event({call,From}, get_count, Data) ->
  %% Reply with the current count
  {keep_state,Data,[{reply,From,Data}]};
handle_event(_, _, Data) ->
  %% Ignore all other events
  {keep_state,Data}.