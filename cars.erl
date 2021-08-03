%%%-------------------------------------------------------------------
%%% @author eliav
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. אוג׳ 2021 16:43
%%%-------------------------------------------------------------------
-module('cars').
-author("eliav").

-behaviour(gen_statem).

-define(SERVER, ?MODULE).
%% API
%%gen_state functions%%
-export([start_link/0,terminate/3,code_change/4,callback_mode/0,start/3,init/1]).
%states
-export([stright/3,stooping/3]).
%events
-export([car_alert/1,clear_path/0,turn_right/0,turn_left/0,traffic_light_red/1,traffic_light_orange/1,traffic_light_green/1,stop/0,tl_alert/2]).

start_link() ->
  gen_statem:start_link({local, ?SERVER}, ?MODULE, [], []).

start(Cname,Details,Pc)->
  put(cname,Cname),
  gen_statem:start({local,get(cname)},?MODULE,[Cname,Details,Pc],[]).


%%%%%%Api must have func%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init([Cname,Details,Pc])->
  put(details,Details),
  %ets:insert(cars,{Cnum,Details,PC,self()}),
  Data={1,1,u},
  {ok,stright,Data}.
terminate(_Reason, _State, _Data) ->
  void.
code_change(_Vsn, State, Data, _Extra) ->
  {ok,State,Data}.
callback_mode() -> state_functions.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%events%%%%%%%%%%%%%%%%%%%%%%%%
clear_path() ->
  gen_statem:call(yarin, clear_path).

turn_right() ->
  gen_statem:call(get(cname), turn_right).

turn_left() ->
  gen_statem:call(get(cname), turn_left).

car_alert(Car) ->
  gen_statem:call(Car, car_alert).

tl_alert(Car,green)->
  traffic_light_green(Car);
tl_alert(Car,red)->
  traffic_light_red(Car);
tl_alert(Car,yellow)->
  traffic_light_orange(Car).

traffic_light_red(Car)->gen_statem:call(Car, traffic_light_red).

traffic_light_orange(Car)->gen_statem:call(Car, traffic_light_orange).

traffic_light_green(Car)->gen_statem:call(Car, traffic_light_green).

stop() ->
  gen_statem:stop(get(cname)).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%states%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stright({call,From}, clear_path, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  if
    Dir==u->{keep_state,{X,Y+1,Dir},[{reply,From,stright}]};
    Dir==d->{keep_state,{X,Y-1,Dir},[{reply,From,stright}]};
    Dir==r->{keep_state,{X+1,Y,Dir},[{reply,From,stright}]};
    true->{keep_state,{X-1,Y,Dir},[{reply,From,stright}]} end;



stright({call,From}, car_alert, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  {next_state,stooping,Data,[{reply,From,stright}]} ;


stright({call,From}, traffic_light_green, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  if
    Dir==u->{keep_state,{X,Y+1,Dir},[{reply,From,stright}]};
    Dir==d->{keep_state,{X,Y-1,Dir},[{reply,From,stright}]};
    Dir==r->{keep_state,{X+1,Y,Dir},[{reply,From,stright}]};
    true->{keep_state,{X-1,Y,Dir},[{reply,From,stright}]} end;


stright({call,From}, traffic_light_red, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  {next_state,stooping,Data,[{reply,From,stright}]} ;

stright({call,From}, traffic_light_orange, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  {next_state,stooping,Data,[{reply,From,stright}]} ;


stright({call,From}, turn_right, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  if
    Dir==u->{keep_state,{X+1,Y,r},[{reply,From,stright}]};
    Dir==d->{keep_state,{X+1,Y,r},[{reply,From,stright}]};
    Dir==r->{keep_state,{X,Y-1,d},[{reply,From,stright}]};
    true->{keep_state,{X,Y+1,u},[{reply,From,stright}]} end;

stright({call,From}, turn_left, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  if
    Dir==u->{keep_state,{X-1,Y,l},[{reply,From,stright}]};
    Dir==d->{keep_state,{X-1,Y,l},[{reply,From,stright}]};
    Dir==r->{keep_state,{X,Y+1,u},[{reply,From,stright}]};
    true->{keep_state,{X,Y-1,d},[{reply,From,stright}]} end.



stooping({call,From}, car_alert, Data)->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,Data,[{reply,From,stright}]};

stooping({call,From}, traffic_light_red, Data)->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,Data,[{reply,From,stright}]};

stooping({call,From}, traffic_light_orange, Data)->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,Data,[{reply,From,stright}]};

stooping({call,From}, clear_path, Data)->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  {next_state,stright,Data,[{reply,From,stright}]};

stooping({call,From}, traffic_light_green, Data)->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  {next_state,stright,Data,[{reply,From,stright}]};

stooping({call,From}, turn_right, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  if
    Dir==u->{keep_state,{X+1,Y,r},[{reply,From,stright}]};
    Dir==d->{keep_state,{X+1,Y,r},[{reply,From,stright}]};
    Dir==r->{keep_state,{X,Y-1,d},[{reply,From,stright}]};
    true->{keep_state,{X,Y+1,u},[{reply,From,stright}]} end;

stooping({call,From}, turn_left, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  if
    Dir==u->{keep_state,{X-1,Y,l},[{reply,From,stright}]};
    Dir==d->{keep_state,{X-1,Y,l},[{reply,From,stright}]};
    Dir==r->{keep_state,{X,Y+1,u},[{reply,From,stright}]};
    true->{keep_state,{X,Y-1,d},[{reply,From,stright}]} end.
