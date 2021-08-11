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
-include("header.hrl").
-define(SERVER, ?MODULE).
%-define(Server1, 'eliav4670@yarinabutbul-VirtualBox').
%-define(Server2, 'eliav4670@yarinabutbul-VirtualBox').
%-define(Server3, 'eliav4670@yarinabutbul-VirtualBox').
%-define(Server4, 'eliav4670@yarinabutbul-VirtualBox').
%% API
%%gen_state functions%%
-export([start_link/0,terminate/3,code_change/4,callback_mode/0,start/5,init/1]).
%states
-export([stright/3,stooping/3]).
%events
-export([junc_alert/3,car_alert/2,timeout/1,clear_path/1,turn_south/1,turn_north/1,turn_east/1,turn_west/1,traffic_light_red/1,traffic_light_orange/1,traffic_light_green/1,stop/1,tl_alert/2,switch_area/2]).

start_link() ->
  gen_statem:start_link({local, ?SERVER}, ?MODULE, [], []).

start(Cname,Details,Pc,Dir,Road)->
  put(cname,Cname),
  gen_statem:start({local,get(cname)},?MODULE,[Cname,Details,Pc,Cname,Dir,Road],[]).


%%%%%%Api must have func%%%%%%%%%%%%%%%%%%%%%ERL%%%%%%%%%
init([Cname,X,Y,Cname,Dir,Road])->%spwan all the sensors

  Data={X,Y,Dir,Cname},
  ets:insert(cars,{Cname,Road,{X,Y},0,Dir,red}),
  %io:format("ets: ~p~n",[ets:lookup(cars,Cname)]),
  %io:format("first junc ~p~n",[ets:lookup(ets:first(junction)])),
  SensorPid = spawn(alerts,junc_alert,[Cname,ets:first(junction)]), % spawn all car sensors, add them to their ets and put them in process dictionary
  SensorPid2 = spawn(alerts,tl_alert,[Cname,ets:first(traffic_light)]), % spawn all car sensors, add them to their ets and put them in process dictionary
  SensorPid3 = spawn(alerts,car_alert,[Cname,ets:first(cars)]),
  SensorPid4 = spawn(alerts,switch_area,[Cname]),
  {ok,stright,Data,50}.
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

junc_alert(Car,west,NewRoad)-> ets:update_element(cars,Car,[{2,NewRoad},{5,west}]),turn_west(Car);
junc_alert(Car,east,NewRoad)->ets:update_element(cars,Car,[{2,NewRoad},{5,east}]),turn_east(Car);
junc_alert(Car,north,NewRoad)->ets:update_element(cars,Car,[{2,NewRoad},{5,north}]),turn_north(Car);
junc_alert(Car,south,NewRoad)->ets:update_element(cars,Car,[{2,NewRoad},{5,south}]),turn_south(Car).


traffic_light_red(Car)->gen_statem:call(Car, traffic_light_red).

traffic_light_orange(Car)->gen_statem:call(Car, traffic_light_orange).

traffic_light_green(Car)->gen_statem:call(Car, traffic_light_green).

switch_area(Car,server1)-> [{CarNumber1,Road,{Cx,Cy},_Speed,Dir,_Color}]=ets:lookup(cars,Car),gen_server:cast({server,?Server1},{start_car,CarNumber1,Cx,Cy,Dir,Road},
                          ets:delete(cars,Car)),stop(Car);
switch_area(Car,server2)-> [{CarNumber1,Road,{Cx,Cy},_Speed,Dir,_Color}]=ets:lookup(cars,Car),gen_server:cast({server,?Server2},{start_car,CarNumber1,Cx,Cy,Dir,Road},
  ets:delete(cars,Car)),stop(Car);
switch_area(Car,server3)-> [{CarNumber1,Road,{Cx,Cy},_Speed,Dir,_Color}]=ets:lookup(cars,Car),gen_server:cast({server,?Server3},{start_car,CarNumber1,Cx,Cy,Dir,Road},
  ets:delete(cars,Car)),stop(Car);
switch_area(Car,server4)-> [{CarNumber1,Road,{Cx,Cy},_Speed,Dir,_Color}]=ets:lookup(cars,Car),gen_server:cast({server,?Server4},{start_car,CarNumber1,Cx,Cy,Dir,Road},
  ets:delete(cars,Car)),stop(Car).

stop(Car) ->
  gen_statem:stop(Car).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%states%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stright({call,From}, clear_path, Data) ->
  {X,Y,Dir,Cname}=Data,
  io:format("{~p,~p,~p, ets:~p}",[X,Y,Dir,ets:lookup(cars,Cname)]),
  if
    Dir==south-> ets:update_element(cars,Cname,[{3,{X,Y+1}},{5,south}]),{keep_state,{X,Y+1,Dir,Cname},[{state_timeout,50,time}]};
    Dir==north->  ets:update_element(cars,Cname,[{3,{X,Y-1}},{5,north}]),{keep_state,{X,Y-1,Dir,Cname},[{state_timeout,50,time}]};
    Dir==west->  ets:update_element(cars,Cname,[{3,{X-1,Y}},{5,west}]),{keep_state,{X-1,Y,Dir,Cname},[{state_timeout,50,time}]};
    true->  ets:update_element(cars,Cname,[{3,{X+1,Y}},{5,east}]),{keep_state,{X+1,Y,Dir,Cname}, [{state_timeout,50,time}]}end;

stright(state_timeout, time,  Data) ->
  {X,Y,Dir,Cname}=Data,
  io:format("{~p,~p,~p, ets:~p}",[X,Y,Dir,ets:lookup(cars,Cname)]),
  if
    Dir==south->  ets:update_element(cars,Cname,[{3,{X,Y+1}},{5,south}]),{keep_state,{X,Y+1,Dir,Cname},[{state_timeout,50,time}]};
    Dir==north-> ets:update_element(cars,Cname,[{3,{X,Y-1}},{5,north}]),{keep_state,{X,Y-1,Dir,Cname},[{state_timeout,50,time}]};
    Dir==west-> ets:update_element(cars,Cname,[{3,{X-1,Y}},{5,west}]),{keep_state,{X-1,Y,Dir,Cname},[{state_timeout,50,time}]};
    true-> ets:update_element(cars,Cname,[{3,{X+1,Y}},{5,east}]),{keep_state,{X+1,Y,Dir,Cname},[{state_timeout,50,time}]} end;

stright(timeout, 50,  Data) ->
  {X,Y,Dir,Cname}=Data,
  io:format("{~p,~p,~p, ets:~p}",[X,Y,Dir,ets:lookup(cars,Cname)]),
  if
    Dir==south-> ets:update_element(cars,Cname,[{3,{X,Y+1}},{5,south}]),{keep_state,{X,Y+1,Dir,Cname},[{state_timeout,50,time}]};
    Dir==north->ets:update_element(cars,Cname,[{3,{X,Y-1}},{5,north}]),{keep_state,{X,Y-1,Dir,Cname},[{state_timeout,50,time}]};
    Dir==west->ets:update_element(cars,Cname,[{3,{X-1,Y}},{5,west}]),{keep_state,{X-1,Y,Dir,Cname},[{state_timeout,50,time}]};
    true->ets:update_element(cars,Cname,[{3,{X+1,Y}},{5,east}]),{keep_state,{X+1,Y,Dir,Cname},[{state_timeout,50,time}]} end;



stright({call,From}, {car_alert,Car2}, Data) ->
  {X,Y,Dir,Cname}=Data,
  %io:format("{~p,~p,~p, ets:~p}",[X,Y,Dir,ets:lookup(cars,Cname)]),
  {next_state,stooping,Data,[{reply,From,stright}]} ;


stright({call,From}, traffic_light_green, Data) ->
  {X,Y,Dir,Cname}=Data,
  %io:format("{~p,~p,~p, ets:~p}",[X,Y,Dir,ets:lookup(cars,Cname)]),
  if
    Dir==south-> ets:update_element(cars,Cname,[{3,{X,Y+1}},{5,south}]),{keep_state,{X,Y+1,Dir,Cname},[{state_timeout,50,time}]};
    Dir==north-> ets:update_element(cars,Cname,[{3,{X,Y-1}},{5,north}]),{keep_state,{X,Y-1,Dir,Cname},[{state_timeout,50,time}]};
    Dir==west-> ets:update_element(cars,Cname,[{3,{X-1,Y}},{5,west}]),{keep_state,{X-1,Y,Dir,Cname},[{state_timeout,50,time}]};
    true-> ets:update_element(cars,Cname,[{3,{X+1,Y}},{5,east}]),{keep_state,{X+1,Y,Dir,Cname},[{state_timeout,50,time}]} end;


stright({call,From}, traffic_light_red, Data) ->
  {X,Y,Dir,Cname}=Data,
  %io:format("{~p,~p,~p, ets:~p}",[X,Y,Dir,ets:lookup(cars,Cname)]),
  {next_state,stooping,Data,[{reply,From,stright}]} ;

stright({call,From}, traffic_light_orange, Data) ->
  {X,Y,Dir,Cname}=Data,
  %io:format("{~p,~p,~p, ets:~p}",[X,Y,Dir,ets:lookup(cars,Cname)]),
  {next_state,stooping,Data,[{reply,From,stright}]} ;


stright({call,From}, turn_south, Data) ->
  {X,Y,Dir,Cname}=Data,
  ets:update_element(cars,Cname,[{3,{X,Y+1}},{5,south}]),
  io:format("{~p,~p,~p}",[X,Y,Dir]),{keep_state,{X,Y+1,south,Cname},[{reply,From,stright}]};

stright({call,From}, turn_north, Data) ->
  {X,Y,Dir,Cname}=Data,
  ets:update_element(cars,Cname,[{3,{X,Y-1}},{5,north}]),
  io:format("{~p,~p,~p}",[X,Y,Dir]),{keep_state,{X,Y-1,north,Cname},[{reply,From,stright}]};

stright({call,From}, turn_east, Data) ->
  {X,Y,Dir,Cname}=Data,
  ets:update_element(cars,Cname,[{3,{X+1,Y}},{5,east}]),
  io:format("{~p,~p,~p}",[X,Y,Dir]),{keep_state,{X+1,Y,east,Cname},[{reply,From,stright}]};

stright({call,From}, turn_west, Data) ->
  {X,Y,Dir,Cname}=Data,
  ets:update_element(cars,Cname,[{3,{X-1,Y}},{5,west}]),
  io:format("{~p,~p,~p}",[X,Y,Dir]),{keep_state,{X-1,Y,west,Cname},[{reply,From,stright}]}.


stooping({call,From}, {car_alert,Car2}, Data)->
  {X,Y,Dir,Cname}=Data,
  SensorPid4=spawn(alerts,clear_path,[Cname,Car2]),
  %io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,Data,[{reply,From,stright}]};

stooping({call,From}, traffic_light_red, Data)->
  {X,Y,Dir,Cname}=Data,
  %io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,Data,[{reply,From,stright}]};

stooping({call,From}, traffic_light_orange, Data)->
  {X,Y,Dir,Cname}=Data,
  %io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,Data,[{reply,From,stright}]};

stooping({call,From}, clear_path, Data)->
  {X,Y,Dir,Cname}=Data,
  %io:format("{~p,~p,~p}",[X,Y,Dir]),
  {next_state,stright,Data,[{reply,From,stright}]};

stooping({call,From}, traffic_light_green, Data)->
  {X,Y,Dir,Cname}=Data,
  %io:format("{~p,~p,~p,satte=stooping gren}",[X,Y,Dir]),
  {next_state,stright,Data,[{reply,From,stright}]};

stooping({call,From}, turn_south, Data) ->
  {X,Y,Dir,Cname}=Data,
  %io:format("{~p,~p,~p}",[X,Y,Dir]),
  ets:update_element(cars,Cname,[{3,{X,Y+1}},{5,south}]),
  {keep_state,{X,Y+1,south,Cname},[{reply,From,stright}]};

stooping({call,From}, turn_north, Data) ->
  {X,Y,Dir,Cname}=Data,
  %io:format("{~p,~p,~p}",[X,Y,Dir]),
  ets:update_element(cars,Cname,[{3,{X,Y-1}},{5,north}]),
  {keep_state,{X,Y-1,north,Cname},[{reply,From,stright}]};

stooping({call,From}, turn_west, Data) ->
  {X,Y,Dir,Cname}=Data,
  %io:format("{~p,~p,~p}",[X,Y,Dir]),
  ets:update_element(cars,Cname,[{3,{X-1,Y}},{5,west}]),
  {keep_state,{X-1,Y,west,Cname},[{reply,From,stright}]};

stooping({call,From}, turn_east, Data) ->
  {X,Y,Dir,Cname}=Data,
  %io:format("{~p,~p,~p}",[X,Y,Dir]),
  ets:update_element(cars,Cname,[{3,{X+1,Y}},{5,east}]),
  {keep_state,{X+1,Y,east,Cname},[{reply,From,stright}]}.