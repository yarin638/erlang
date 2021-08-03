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
-export([junc_alert/3,car_alert/2,timeout/1,clear_path/1,turn_south/1,turn_north/1,turn_east/1,turn_west/1,traffic_light_red/1,traffic_light_orange/1,traffic_light_green/1,stop/0,tl_alert/2]).

start_link() ->
  gen_statem:start_link({local, ?SERVER}, ?MODULE, [], []).

start(Cname,Details,Pc)->
  put(cname,Cname),
  gen_statem:start({local,get(cname)},?MODULE,[Cname,Details,Pc],[]).


%%%%%%Api must have func%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init([Cname,Details,Pc])->%spwan all the sensors
  put(details,Details),
  Data={1,1,north},
  {ok,stright,Data}.
terminate(_Reason, _State, _Data) ->
  void.
code_change(_Vsn, State, Data, _Extra) ->
  {ok,State,Data}.
callback_mode() -> state_functions.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%events%%%%%%%%%%%%%%%%%%%%%%%%
clear_path(Car) ->
  gen_statem:call(Car,clear_path).

timeout(Car) ->
  gen_statem:call(Car,{time}).

turn_west(Car) ->
  gen_statem:call(Car, turn_west).

turn_east(Car) ->
  gen_statem:call(Car, turn_east).

turn_north(Car) ->
  gen_statem:call(Car, turn_north).

turn_south(Car) ->
  gen_statem:call(Car, turn_south).

car_alert(Car,Car2) ->
  gen_statem:call(Car, {car_alert,Car2}).


tl_alert(Car,green)->
  traffic_light_green(Car);
tl_alert(Car,red)->
  traffic_light_red(Car);
tl_alert(Car,yellow)->
  traffic_light_orange(Car).

junc_alert(Car,west,NewRoad)-> turn_west(Car);
junc_alert(Car,east,NewRoad)->turn_east(Car);
junc_alert(Car,north,NewRoad)->turn_north(Car);
junc_alert(Car,south,NewRoad)->turn_south(Car).


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
    Dir==north->{keep_state,{X,Y+1,Dir},[{state_timeout,1000,time}]};
    Dir==south->{keep_state,{X,Y-1,Dir},[{state_timeout,1000,time}]};
    Dir==west->{keep_state,{X+1,Y,Dir},[{state_timeout,1000,time}]};
    true->{keep_state,{X-1,Y,Dir}, [{state_timeout,1000,time}]}end;

stright(state_timeout, time,  Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  if
    Dir==north->{keep_state,{X,Y+1,Dir},[{state_timeout,1000,time}]};
    Dir==south->{keep_state,{X,Y-1,Dir},[{state_timeout,1000,time}]};
    Dir==west->{keep_state,{X+1,Y,Dir},[{state_timeout,1000,time}]};
    true->{keep_state,{X-1,Y,Dir},[{state_timeout,1000,time}]} end;



stright({call,From}, {car_alert,Car2}, Data) ->
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


stright({call,From}, turn_north, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),{keep_state,{X,Y+1,north},[{reply,From,stright}]};

stright({call,From}, turn_south, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),{keep_state,{X,Y-1,south},[{reply,From,stright}]};

stright({call,From}, turn_east, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),{keep_state,{X+1,Y,east},[{reply,From,stright}]};

stright({call,From}, turn_west, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),{keep_state,{X-1,Y,west},[{reply,From,stright}]}.


stooping({call,From}, {car_alert,Car2}, Data)->
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

stooping({call,From}, turn_north, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,{X,Y+1,r},[{reply,From,stright}]};

stooping({call,From}, turn_south, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,{X,Y-1,r},[{reply,From,stright}]};

stooping({call,From}, turn_west, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,{X-1,Y,r},[{reply,From,stright}]};

stooping({call,From}, turn_east, Data) ->
  {X,Y,Dir}=Data,
  io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,{X+1,Y,r},[{reply,From,stright}]}.