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
  gen_statem:start({local,Cname},?MODULE,[Cname,Details,Pc,Cname,Dir,Road],[]).


%%%%%%Api must have func%%%%%%%%%%%%%%%%%%%%%ERL%%%%%%%%%
init([Cname,X,Y,Cname,Dir,Road])->%spwan all the sensors

  Data={X,Y,Dir,Cname},%enter the data 
  ets:insert(cars,{Cname,Road,{X,Y},0,Dir,red}),
  case ets:member(cars_stats,Cname) of
    false-> ets:insert(cars_stats,{Cname,erlang:timestamp(),0,0,0});
    true-> ets:update_element(cars_stat,Cname,[{1,erlang:timestamp()}])
  end,
  %io:format("ets: ~p~n",[ets:lookup(cars,Cname)]),
  %io:format("first junc ~p~n",[ets:lookup(ets:first(junction)])),
  SensorPid = spawn(alerts,junc_alert,[Cname,ets:first(junction)]), % spawn all car sensors, add them to their ets and put them in process dictionary
  SensorPid2 = spawn(alerts,tl_alert,[Cname,ets:first(traffic_light)]), % spawn all car sensors, add them to their ets and put them in process dictionary
  SensorPid3 = spawn(alerts,car_alert,[Cname,ets:first(cars)]),
  SensorPid4 = spawn(alerts,switch_area,[Cname,SensorPid,SensorPid2,SensorPid3]),
  put(sens1,SensorPid),  put(sens2,SensorPid2),  put(sens3,SensorPid3),  put(sens4,SensorPid4),
  %register(sensorPid1,SensorPid),
  %register(sensorPid2,SensorPid2),
  %register(sensorPid3,SensorPid3),
  %register(sensorPid4,SensorPid4),
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
tl_alert(Car,yellowFormRed)->
  traffic_light_orange(Car);
tl_alert(Car,yellowFormGreen)->
  traffic_light_orange(Car).

junc_alert(Car,west,NewRoad)-> ets:update_element(cars,Car,[{2,NewRoad},{5,west}]),turn_west(Car);
junc_alert(Car,east,NewRoad)->ets:update_element(cars,Car,[{2,NewRoad},{5,east}]),turn_east(Car);
junc_alert(Car,north,NewRoad)->ets:update_element(cars,Car,[{2,NewRoad},{5,north}]),turn_north(Car);
junc_alert(Car,south,NewRoad)->ets:update_element(cars,Car,[{2,NewRoad},{5,south}]),turn_south(Car).


traffic_light_red(Car)->gen_statem:call(Car, traffic_light_red).

traffic_light_orange(Car)->gen_statem:call(Car, traffic_light_orange).

traffic_light_green(Car)->gen_statem:call(Car, traffic_light_green).




switch_area(Car,server1)->gen_statem:cast(Car,move_car1),exit(kill);
switch_area(Car,server2)->gen_statem:cast(Car,move_car2),exit(kill);
switch_area(Car,server3)->gen_statem:cast(Car,move_car3),exit(kill);
switch_area(Car,server4)->gen_statem:cast(Car,move_car4),exit(kill).


%switch_area(Car,server1)->[{CarNumber1,Road,{Cx,Cy},_Speed,Dir,_Color}]=ets:lookup(cars,Car),
% gen_server:cast({server,?Server1},{start_car,CarNumber1,Cx,Cy,Dir,Road},
%  exit(whereis(sensorPid1),kill), exit(whereis(sensorPid2),kill), exit(whereis(sensorPid3),kill), exit(whereis(sensorPid4),kill),ets:delete(cars,Car)),stop(Car);
%switch_area(Car,server2)->  [{CarNumber1,Road,{Cx,Cy},_Speed,Dir,_Color}]=ets:lookup(cars,Car),
% gen_server:cast({server,?Server2},{start_car,CarNumber1,Cx,Cy,Dir,Road},
%  exit(whereis(sensorPid1),kill), exit(whereis(sensorPid2),kill), exit(whereis(sensorPid3),kill), exit(whereis(sensorPid4),kill),ets:delete(cars,Car)),stop(Car);
%switch_area(Car,server3)->  [{CarNumber1,Road,{Cx,Cy},_Speed,Dir,_Color}]=ets:lookup(cars,Car),
% gen_server:cast({server,?Server3},{start_car,CarNumber1,Cx,Cy,Dir,Road},
%  exit(whereis(sensorPid1),kill), exit(whereis(sensorPid2),kill), exit(whereis(sensorPid3),kill), exit(whereis(sensorPid4),kill),ets:delete(cars,Car)),stop(Car);
%switch_area(Car,server4)->  [{CarNumber1,Road,{Cx,Cy},_Speed,Dir,_Color}]=ets:lookup(cars,Car),
% gen_server:cast({server,?Server4},{start_car,CarNumber1,Cx,Cy,Dir,Road},
%  exit(whereis(sensorPid1),kill), exit(whereis(sensorPid2),kill), exit(whereis(sensorPid3),kill), exit(whereis(sensorPid4),kill),ets:delete(cars,Car)),stop(Car).


stop(Car) ->
  gen_statem:stop(Car).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%states%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stright(cast, move_car1, Data) ->
  [{_,Status1}]=ets:lookup(servers,?Server1),
  {_,_,_,Cname}=Data,
  update_time(Cname,move_area),
  [{CarNumber1,Road,{Cx,Cy},_Speed,Dir,_Color}]=ets:lookup(cars,Cname),
  if
    Status1==on->
  case Dir of
    west->gen_server:cast({server,?Server1},{start_car,CarNumber1,Cx-3,Cy,Dir,Road});
    north->gen_server:cast({server,?Server1},{start_car,CarNumber1,Cx,Cy-3,Dir,Road})
  end;
    true->  case Dir of
              west -> sendToNextServer(CarNumber1,Cx-3,Cy,Dir,Road,ets:first(servers));
              north->sendToNextServer(CarNumber1,Cx,Cy+3,Dir,Road,ets:first(servers))end end,

  ets:update_element(cars,Cname,[{2,400},{3,{100000,10000}},{5,south}]),
  %exit(get(sens1),kill), exit(get(sens2),kill), exit(get(sens3),kill), exit(get(sens4),kill),
  %ets:delete(cars,Cname),
  {next_state,stooping,Data};

stright(cast, move_car2, Data) ->
  [{_,Status2}]=ets:lookup(servers,?Server2),
  {_,_,_,Cname}=Data,
  update_time(Cname,move_area),
  [{CarNumber1,Road,{Cx,Cy},_Speed,Dir,_Color}]=ets:lookup(cars,Cname),
  if
    Status2==on->
  case Dir of
    west->gen_server:cast({server,?Server2},{start_car,CarNumber1,Cx-3,Cy,Dir,Road});
    south->gen_server:cast({server,?Server2},{start_car,CarNumber1,Cx,Cy+3,Dir,Road})
  end;
      true->  case Dir of
       west -> sendToNextServer(CarNumber1,Cx-3,Cy,Dir,Road,ets:first(servers));
               south->sendToNextServer(CarNumber1,Cx,Cy+3,Dir,Road,ets:first(servers))end end,
  ets:update_element(cars,Cname,[{2,400},{3,{100000,10000}},{5,south}]),
  %exit(get(sens1),kill), exit(get(sens2),kill), exit(get(sens3),kill), exit(get(sens4),kill),
  %ets:delete(cars,Cname),
  {next_state,stooping,Data};

stright(cast, move_car3, Data) ->
  {_,_,_,Cname}=Data,
  update_time(Cname,move_area),
  [{CarNumber1,Road,{Cx,Cy},_Speed,Dir,_Color}]=ets:lookup(cars,Cname),
  [{_,Status3}]=ets:lookup(servers,?Server3),
  if
    Status3==on->
  case Dir of
    east->gen_server:cast({server,?Server3},{start_car,CarNumber1,Cx+3,Cy,Dir,Road});
    south->gen_server:cast({server,?Server3},{start_car,CarNumber1,Cx,Cy+3,Dir,Road})
  end;
    true->  case Dir of
              east -> sendToNextServer(CarNumber1,Cx+3,Cy,Dir,Road,ets:first(servers));
              south->sendToNextServer(CarNumber1,Cx,Cy+3,Dir,Road,ets:first(servers))end end,
  ets:update_element(cars,Cname,[{2,400},{3,{100000,10000}},{5,south}]),
  % exit(get(sens1),kill), exit(get(sens2),kill), exit(get(sens3),kill), exit(get(sens4),kill),
  %ets:delete(cars,Cname),
  {next_state,stooping,Data} ;

stright(cast, move_car4, Data) ->
  [{_,Status4}]=ets:lookup(servers,?Server4),
  {_,_,_,Cname}=Data,
  update_time(Cname,move_area),
  %io:format("in statem"),
  [{CarNumber1,Road,{Cx,Cy},_Speed,Dir,_Color}]=ets:lookup(cars,Cname),
  if
   Status4==on->
  case Dir of
    east->gen_server:cast({server,?Server4},{start_car,CarNumber1,Cx+3,Cy,Dir,Road});
    north->gen_server:cast({server,?Server4},{start_car,CarNumber1,Cx,Cy-3,Dir,Road})
  end;
     true->
       case Dir of
         east -> sendToNextServer(CarNumber1,Cx+3,Cy,Dir,Road,ets:first(servers));
         north->sendToNextServer(CarNumber1,Cx,Cy-3,Dir,Road,ets:first(servers))end
         end,
  %io:format("after lookup"),
  ets:update_element(cars,Cname,[{2,400},{3,{100000,10000}},{5,south}]),
  %exit(get(sens1),kill), exit(get(sens2),kill), exit(get(sens3),kill), exit(get(sens4),kill),
  %ets:delete(cars,Cname),
  {next_state,stooping,Data} ;


stright({call,_From}, clear_path, Data) ->
  {X,Y,Dir,Cname}=Data,
  %io:format("{~p,~p,~p, ets:~p}",[X,Y,Dir,ets:lookup(cars,Cname)]),
  if
    Dir==south-> ets:update_element(cars,Cname,[{3,{X,Y+1}},{5,south}]),{keep_state,{X,Y+1,Dir,Cname},[{state_timeout,50,time}]};
    Dir==north->  ets:update_element(cars,Cname,[{3,{X,Y-1}},{5,north}]),{keep_state,{X,Y-1,Dir,Cname},[{state_timeout,50,time}]};
    Dir==west->  ets:update_element(cars,Cname,[{3,{X-1,Y}},{5,west}]),{keep_state,{X-1,Y,Dir,Cname},[{state_timeout,50,time}]};
    true->  ets:update_element(cars,Cname,[{3,{X+1,Y}},{5,east}]),{keep_state,{X+1,Y,Dir,Cname}, [{state_timeout,50,time}]}end;

stright(state_timeout, time,  Data) ->
  {X,Y,Dir,Cname}=Data,
  %io:format("{~p,~p,~p, ets:~p}",[X,Y,Dir,ets:lookup(cars,Cname)]),
  if
    Dir==south->  ets:update_element(cars,Cname,[{3,{X,Y+1}},{5,south}]),{keep_state,{X,Y+1,Dir,Cname},[{state_timeout,50,time}]};
    Dir==north-> ets:update_element(cars,Cname,[{3,{X,Y-1}},{5,north}]),{keep_state,{X,Y-1,Dir,Cname},[{state_timeout,50,time}]};
    Dir==west-> ets:update_element(cars,Cname,[{3,{X-1,Y}},{5,west}]),{keep_state,{X-1,Y,Dir,Cname},[{state_timeout,50,time}]};
    true-> ets:update_element(cars,Cname,[{3,{X+1,Y}},{5,east}]),{keep_state,{X+1,Y,Dir,Cname},[{state_timeout,50,time}]} end;

stright(timeout, 50,  Data) ->
  {X,Y,Dir,Cname}=Data,
  %io:format("{~p,~p,~p, ets:~p}",[X,Y,Dir,ets:lookup(cars,Cname)]),
  if
    Dir==south-> ets:update_element(cars,Cname,[{3,{X,Y+1}},{5,south}]),{keep_state,{X,Y+1,Dir,Cname},[{state_timeout,50,time}]};
    Dir==north->ets:update_element(cars,Cname,[{3,{X,Y-1}},{5,north}]),{keep_state,{X,Y-1,Dir,Cname},[{state_timeout,50,time}]};
    Dir==west->ets:update_element(cars,Cname,[{3,{X-1,Y}},{5,west}]),{keep_state,{X-1,Y,Dir,Cname},[{state_timeout,50,time}]};
    true->ets:update_element(cars,Cname,[{3,{X+1,Y}},{5,east}]),{keep_state,{X+1,Y,Dir,Cname},[{state_timeout,50,time}]} end;


stright({call,From}, {car_alert,Car2}, Data) ->
  {_X,__Y,_Dir,Cname}=Data,
  update_time(Cname,stop),
  spawn(alerts,clear_path,[Cname,Car2]),
  %io:format("{~p,~p,~p, ets:~p}",[X,Y,Dir,ets:lookup(cars,Cname)]),
  {next_state,stooping,Data,[{reply,From,stright}]} ;


stright({call,_From}, traffic_light_green, Data) ->
  {X,Y,Dir,Cname}=Data,
  %io:format("{~p,~p,~p, ets:~p}",[X,Y,Dir,ets:lookup(cars,Cname)]),
  if
    Dir==south-> ets:update_element(cars,Cname,[{3,{X,Y+1}},{5,south}]),{keep_state,{X,Y+1,Dir,Cname},[{state_timeout,50,time}]};
    Dir==north-> ets:update_element(cars,Cname,[{3,{X,Y-1}},{5,north}]),{keep_state,{X,Y-1,Dir,Cname},[{state_timeout,50,time}]};
    Dir==west-> ets:update_element(cars,Cname,[{3,{X-1,Y}},{5,west}]),{keep_state,{X-1,Y,Dir,Cname},[{state_timeout,50,time}]};
    true-> ets:update_element(cars,Cname,[{3,{X+1,Y}},{5,east}]),{keep_state,{X+1,Y,Dir,Cname},[{state_timeout,50,time}]} end;


stright({call,From}, traffic_light_red, Data) ->
  {_X,_Y,_Dir,Cname}=Data,
  update_time(Cname,stop),
  %io:format("{~p,~p,~p, ets:~p}",[X,Y,Dir,ets:lookup(cars,Cname)]),
  {next_state,stooping,Data,[{reply,From,stright}]} ;

stright({call,From}, traffic_light_orange, Data) ->
  {_X,_Y,_Dir,Cname}=Data,
  update_time(Cname,stop),
  %io:format("{~p,~p,~p, ets:~p}",[X,Y,Dir,ets:lookup(cars,Cname)]),
  {next_state,stooping,Data,[{reply,From,stright}]} ;


stright({call,From}, turn_south, Data) ->
  {X,Y,_Dir,Cname}=Data,
  ets:update_element(cars,Cname,[{3,{X,Y+1}},{5,south}]),
  %io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,{X,Y+1,south,Cname},[{reply,From,stright}]};

stright({call,From}, turn_north, Data) ->
  {X,Y,_Dir,Cname}=Data,
  ets:update_element(cars,Cname,[{3,{X,Y-1}},{5,north}]),
  % io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,{X,Y-1,north,Cname},[{reply,From,stright}]};

stright({call,From}, turn_east, Data) ->
  {X,Y,_Dir,Cname}=Data,
  ets:update_element(cars,Cname,[{3,{X+1,Y}},{5,east}]),
  % io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,{X+1,Y,east,Cname},[{reply,From,stright}]};

stright({call,From}, turn_west, Data) ->
  {X,Y,_Dir,Cname}=Data,
  ets:update_element(cars,Cname,[{3,{X-1,Y}},{5,west}]),
  % io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,{X-1,Y,west,Cname},[{reply,From,stright}]}.


stooping({call,From}, {car_alert,Car2}, Data)->
  {_X,_Y,_Dir,Cname}=Data,
  spawn(alerts,clear_path,[Cname,Car2]),
  % io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,Data,[{reply,From,stright}]};

stooping({call,From}, traffic_light_red, Data)->
  {_X,_Y,_Dir,_Cname}=Data,
  %io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,Data,[{reply,From,stright}]};

stooping({call,From}, traffic_light_orange, Data)->
  {_X,_Y,_Dir,_Cname}=Data,
  %io:format("{~p,~p,~p}",[X,Y,Dir]),
  {keep_state,Data,[{reply,From,stright}]};

stooping({call,From}, clear_path, Data)->
  {_X,_Y,_Dir,Cname}=Data,
  update_time(Cname,start_driving),
  %io:format("{~p,~p,~p}",[X,Y,Dir]),
  {next_state,stright,Data,[{reply,From,stright}]};

stooping({call,From}, traffic_light_green, Data)->
  {_X,_Y,_Dir,Cname}=Data,
  update_time(Cname,start_driving),
  %io:format("{~p,~p,~p,satte=stooping gren}",[X,Y,Dir]),
  {next_state,stright,Data,[{reply,From,stright}]};

stooping({call,From}, turn_south, Data) ->
  {X,Y,_Dir,Cname}=Data,
  %io:format("{~p,~p,~p}",[X,Y,Dir]),
  ets:update_element(cars,Cname,[{3,{X,Y+1}},{5,south}]),
  {keep_state,{X,Y+1,south,Cname},[{reply,From,stright}]};

stooping({call,From}, turn_north, Data) ->
  {X,Y,_Dir,Cname}=Data,
  %io:format("{~p,~p,~p}",[X,Y,Dir]),
  ets:update_element(cars,Cname,[{3,{X,Y-1}},{5,north}]),
  {keep_state,{X,Y-1,north,Cname},[{reply,From,stright}]};

stooping({call,From}, turn_west, Data) ->
  {X,Y,_Dir,Cname}=Data,
  %io:format("{~p,~p,~p}",[X,Y,Dir]),
  ets:update_element(cars,Cname,[{3,{X-1,Y}},{5,west}]),
  {keep_state,{X-1,Y,west,Cname},[{reply,From,stright}]};

stooping({call,From}, turn_east, Data) ->
  {X,Y,_Dir,Cname}=Data,
  %io:format("{~p,~p,~p}",[X,Y,Dir]),
  ets:update_element(cars,Cname,[{3,{X+1,Y}},{5,east}]),
  {keep_state,{X+1,Y,east,Cname},[{reply,From,stright}]}.


update_time(Car,start_driving)->
  [{Cname,_TimerD,TimerS,_Drive,Stop}]=ets:lookup(cars_stats,Car),
  New_Time=timer:now_diff(erlang:timestamp(),TimerS),
  ets:update_element(cars_stats,Cname,[{2,erlang:timestamp()},{3,0},{5,Stop+New_Time}]);
update_time(Car,stop)->
%  io:format("ets: ~p~n",[ets:lookup(cars,Car)]),
  [{Cname,TimerD,_TimerS,Drive,_Stop}]=ets:lookup(cars_stats,Car),
  New_Time=timer:now_diff(erlang:timestamp(),TimerD),
  ets:update_element(cars_stats,Cname,[{2,0},{3,erlang:timestamp()},{4,Drive+New_Time}]);
update_time(Car,move_area)->
  [{Cname,TimerD,_TimerS,Drive,_Stop}]=ets:lookup(cars_stats,Car),
  New_Time=timer:now_diff(erlang:timestamp(),TimerD),
  ets:update_element(cars_stats,Cname,[{2,0},{3,0},{4,Drive+New_Time}]).



sendToNextServer(CarNumber1,Cx,Cy,Dir,Road,Server)-> [{_,Status}]=ets:lookup(servers,Server),
                                      if Status==off->sendToNextServer(CarNumber1,Cx,Cy,Dir,Road,ets:next(servers,Server));
                                        true->gen_server:cast({server,Server},{start_car,CarNumber1,Cx,Cy,Dir,Road}) end.

