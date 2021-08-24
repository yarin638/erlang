%%-------------------------------------------------------------------
%%% @author eliav
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. אוג׳ 2021 17:54
%%%-------------------------------------------------------------------
-module(main).
-author("eliav").
-include("header.hrl").
-behaviour(wx_object).
-include_lib("wx/include/wx.hrl").
-define(SERVER, ?MODULE).
%-define(Server1, 'eliav4670@yarinabutbul-VirtualBox').
%-define(Server2, 'eliav4670@yarinabutbul-VirtualBox').
%-define(Server3, 'eliav4670@yarinabutbul-VirtualBox').
%-define(Server4, 'eliav4670@yarinabutbul-VirtualBox').

-export([start/0,init/1,handle_event/2,handle_info/2,handle_sync_event/3,check_PC/1]).
-define(Mx,781).
-define(My,1024).
-define(Timer,67).
-record(state,{frame, panel, paint,map,redcarn,redcarw,redcare,redcars,green,red,yellow}).


start() ->
  wx_object:start({local,?SERVER},?MODULE,[],[]).

init([])->
  ets:new(cars,[set,public,named_table]),
  ets:new(servers,[set,public,named_table]),
  ets:new(junction,[set,public,named_table]),ets:new(traffic_light,[set,public,named_table]),
  ets:new(traffic_light_number,[set,public,named_table]),
  ets:insert(traffic_light_number,{number,1}),
  ets:insert(servers,{?Server1,on}),
  ets:insert(servers,{?Server2,on}),
  ets:insert(servers,{?Server3,on}),
  ets:insert(servers,{?Server4,on}),
  rpc:call(?Server1,server,start_link,[]),
  rpc:call(?Server2,server,start_link,[]),
  rpc:call(?Server3,server,start_link,[]),
  rpc:call(?Server4,server,start_link,[]),
  %%start traffic_light%
  gen_server:cast({server,?Server1},{start_traffic_light,1,120,130,red,t1}),
  %ets:insert(traffic_light,{t1,1,120,130,red,?Server1}),

  gen_server:cast({server,?Server1},{start_traffic_light,2,140,40,green,t2}),
  %ets:insert(traffic_light,{t2,2,140,40,green,?Server1}),

  gen_server:cast({server,?Server4},{start_traffic_light,4,340,130,red,t3}),
  %ets:insert(traffic_light,{t3,4,340,130,red,?Server4}),

  gen_server:cast({server,?Server4},{start_traffic_light,5,430,160,green,t4}),
  %ets:insert(traffic_light,{t4,5,395,160,green,?Server4}),

  gen_server:cast({server,?Server4},{start_traffic_light,6,590,130,green,t5}),
  %ets:insert(traffic_light,{t5,6,590,95,green,?Server4}),

  gen_server:cast({server,?Server4},{start_traffic_light,7,680,150,red,t6}),
  %ets:insert(traffic_light,{t6,7,645,150,red,?Server4}),

  gen_server:cast({server,?Server4},{start_traffic_light,10,360,380,red,t18}),
  %ets:insert(traffic_light,{t18,10,360,345,red,?Server4}),

  gen_server:cast({server,?Server4},{start_traffic_light,35,360,310,green,t19}),
  %ets:insert(traffic_light,{t19,35,395,310,green,?Server4}),

  gen_server:cast({server,?Server2},{start_traffic_light,13,120,560,red,t7}),
  gen_server:cast({server,?Server2},{start_traffic_light,9,120,465,green,t8}),
  gen_server:cast({server,?Server3},{start_traffic_light,14,350,560,red,t10}),
  gen_server:cast({server,?Server3},{start_traffic_light,15,365,465,green,t11}),


  gen_server:cast({server,?Server3},{start_traffic_light,18,590,675,red,t12}),
  gen_server:cast({server,?Server3},{start_traffic_light,24,685,680,green,t13}),
  gen_server:cast({server,?Server3},{start_traffic_light,22,685,815,red,t14}),
  gen_server:cast({server,?Server3},{start_traffic_light,25,700,720,green,t15}),
  gen_server:cast({server,?Server2},{start_traffic_light,12,40,745,red,t16}),
  gen_server:cast({server,?Server2},{start_traffic_light,19,135,760,green,t17}),

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%start junc%%
  gen_server:cast({server,?Server1},{start_junc,{175,95},[1,2],[3,4],[south,east]}),
  ets:insert(junction,{{175,95},[1,2],[3,6],[south,east],?Server1}),

  gen_server:cast({server,?Server4},{start_junc,{395,95},[4,5],[6],[east]}),
  ets:insert(junction,{{395,95},[4,5],[6],[east],?Server4}),

  gen_server:cast({server,?Server4},{start_junc,{645,95},[6,7],[8],[north]}),
  ets:insert(junction,{{645,95},[6,7],[8],[north],?Server4}),

  gen_server:cast({server,?Server1},{start_junc,{175,345},[3],[9,10],[south,east]}),
  ets:insert(junction,{{175,345},[3],[9,10],[south,east],?Server1}),

  gen_server:cast({server,?Server4},{start_junc,{395,345},[10,35],[15],[south]}),
  ets:insert(junction,{{395,345},[10,35],[15],[south],?Server4}),

  gen_server:cast({server,?Server2},{start_junc,{175,520},[9,13],[14],[east]}),
  ets:insert(junction,{{175,520},[9,13],[14],[east],?Server2}),

  gen_server:cast({server,?Server3},{start_junc,{405,520},[14,15],[16],[south]}),
  ets:insert(junction,{{405,520},[14,15],[16],[south],?Server3}),

  gen_server:cast({server,?Server3},{start_junc,{395,635},[16],[17,18],[south,east]}),
  ets:insert(junction,{{395,635},[16],[17,18],[south,east],?Server3}),

  gen_server:cast({server,?Server3},{start_junc,{645,635},[18,24],[26],[north]}),
  ets:insert(junction,{{645,635},[18,24],[26],[north],?Server3}),

  gen_server:cast({server,?Server3},{start_junc,{645,520},[26],[27,34],[east,north]}),
  ets:insert(junction,{{645,520},[26],[27,34],[east,north],?Server3}),

  gen_server:cast({server,?Server3},{start_junc,{645,760},[22,25],[24],[north]}),
  ets:insert(junction,{{645,760},[22,25],[24],[north],?Server3}),

  gen_server:cast({server,?Server2},{start_junc,{80,800},[12,19],[32],[west]}),
  ets:insert(junction,{{80,800},[12,19],[32],[west],?Server2}),

  gen_server:cast({server,?Server2},{start_junc,{80,520},[11],[12,13],[south,east]}),
  ets:insert(junction,{{80,520},[1,2],[12,13],[south,east],?Server2}),

  gen_server:cast({server,?Server3},{start_junc,{405,800},[17],[19,20],[west,south]}),
  ets:insert(junction,{{405,800},[17],[19,20],[west,south],?Server3}),

  gen_server:cast({server,?Server4},{start_junc,{645,220},[34],[33,7],[west,north]}),
  ets:insert(junction,{{645,220},[34],[33,7],[west,north],?Server4}),

  gen_server:cast({server,?Server4},{start_junc,{395,220},[33],[35,5],[south,north]}),
  ets:insert(junction,{{395,220},[33],[33,5],[south,north],?Server4}),

   %%%%start cars%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  gen_server:cast({server,?Server1},{start_car,yarin,175,10,south,2}),
  %ets:insert(cars,{yarin175,2,175,10,south,?Server1}),
  gen_server:cast({server,?Server4},{start_car,lotke,550,95,east,6}),
  gen_server:cast({server,?Server2},{start_car,elioz,0,520,east,11}),
  gen_server:cast({server,?Server4},{start_car,eliav,480,95,east,6}),
  gen_server:cast({server,?Server4},{start_car,yanir,450,220,west,33}),
  gen_server:cast({server,?Server3},{start_car,meitar,570,635,east,18}),
  %gen_server:cast({server,?Server1},{start_car,tal,300,95,east,4}),
  gen_server:cast({server,?Server1},{start_car,daniela,200,345,east,10}),
  %ets:insert(cars,{daniela200,10,200,345,east,?Server1}),
  gen_server:cast({server,?Server3},{start_car,naema,320,520,east,14}),
  gen_server:cast({server,?Server3},{start_car,raviv,405,430,south,15}),
  gen_server:cast({server,?Server1},{start_car,hadar,175,250,south,3}),
  %gen_server:cast({server,?Server4},{start_car,shahar,645,850,north,130}),
  %gen_server:cast({server,?Server3},{start_car,shaar,645,900,north,22}),
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %spawn monitors%
  spawn(main,check_PC,[?Server1]),
  spawn(main,check_PC,[?Server2]),
  spawn(main,check_PC,[?Server3]),
  spawn(main,check_PC,[?Server4]),
 %initiate graphic part%
  WxServer=wx:new(),
  MyFrame=wxFrame:new(WxServer,123,"TrafficMap",[{size,{?Mx,?My}}]),
  MyPanel=wxPanel:new(MyFrame),
  {Map,RedCarW,RedCarN,RedCarE,RedCarS,Green,Red,Yellow}=createMap(),
  wxFrame:show(MyFrame),
  wxPanel:connect(MyPanel, paint, [callback]),
  wxFrame:connect(MyFrame, close_window),
  erlang:send_after(?Timer,self(),timer),
  {MyFrame,#state{frame=MyFrame,panel=MyPanel,map=Map,redcarn=RedCarN,redcarw=RedCarW,redcare=RedCarE,redcars=RedCarS,green=Green,red=Red,yellow=Yellow}}.

handle_info(timer, State=#state{frame = Frame}) ->  % refresh screen for graphics
  wxWindow:refresh(Frame), % refresh screen
  erlang:send_after(?Timer,self(),timer),
  {noreply, State};

handle_info({nodeup,PC},State)->
  io:format("~p nodeup ~n",[PC]),
  {noreply, State}.



handle_event(#wx{event = #wxClose{}},State = #state {frame = Frame}) -> % close window event
  io:format("Printing Statistics:~n"),
  [{_,Status1}]=ets:lookup(servers,?Server1),
  %if server is up, get the statistics and display it%
  case Status1 of on->Ets1=gen_server:call({server,?Server1},stats), Data1=add_last(Ets1,[]),  io:format("area 1:~n"),
    create_Stats(Data1,0,0,0);
    off->ok end,
  [{_,Status2}]=ets:lookup(servers,?Server2),
  case Status2 of on->Ets2=gen_server:call({server,?Server2},stats),  Data2=add_last(Ets2,[]), io:format("area 2:~n"),
    create_Stats(Data2,0,0,0);
    off->ok end,
  [{_,Status3}]=ets:lookup(servers,?Server3),
  case Status3 of on->Ets3=gen_server:call({server,?Server3},stats),Data3=add_last(Ets3,[]), io:format("area 3:~n"),
    create_Stats(Data3,0,0,0);
    off->ok end,
  [{_,Status4}]=ets:lookup(servers,?Server4),
  case Status4 of on->Ets4=gen_server:call({server,?Server4},stats), Data4=add_last(Ets4,[]),  io:format("area 4:~n"),
    create_Stats(Data4,0,0,0);
    off->ok end,
  wxWindow:destroy(Frame),
  wx:destroy(),
  {stop,normal,State}.

handle_sync_event(#wx{event=#wxPaint{}}, _,  _State = #state{panel=MyPanel,map=Map,redcarn=RedCarN,redcarw=RedCarW,redcare=RedCarE,redcars=RedCarS,green=Green,red=Red,yellow=Yellow})->
  DC=wxPaintDC:new(MyPanel),
  wxDC:clear(DC),
  wxDC:drawBitmap(DC,Map,{0,0}),
  %wxDC:drawBitmap(DC,RedCarE,{1,1}),
  %getting information about car location from servers and display it%
  %also get information about traffic light color and display it%
  [{_,Status1}]=ets:lookup(servers,?Server1),
  case Status1 of on->CarS1=gen_server:call({server,?Server1},firstcar),
    TlS1=gen_server:call({server,?Server1},firstTl),
    cars_movement(MyPanel,RedCarN,RedCarW,RedCarS,RedCarE,CarS1,?Server1),
    printTl(MyPanel,Green,Red,Yellow,TlS1,?Server1);
    off->ok end,

  [{_,Status2}]=ets:lookup(servers,?Server2),
  case Status2 of on->  CarS2=gen_server:call({server,?Server2},firstcar),
    cars_movement(MyPanel,RedCarN,RedCarW,RedCarS,RedCarE,CarS2,?Server2),
    TlS2=gen_server:call({server,?Server2},firstTl),
    printTl(MyPanel,Green,Red,Yellow,TlS2,?Server2);
    off->ok end,
  [{_,Status3}]=ets:lookup(servers,?Server3),
  case Status3 of on->  CarS3=gen_server:call({server,?Server3},firstcar),
    cars_movement(MyPanel,RedCarN,RedCarW,RedCarS,RedCarE,CarS3,?Server3),
    TlS3=gen_server:call({server,?Server3},firstTl),
    printTl(MyPanel,Green,Red,Yellow,TlS3,?Server3);
    off-> ok end,

  [{_,Status4}]=ets:lookup(servers,?Server4),
  %io:format("status of server 4:~p~n",[Status4]),
  case Status4 of on->CarS4=gen_server:call({server,?Server4},firstcar),
    cars_movement(MyPanel,RedCarN,RedCarW,RedCarS,RedCarE,CarS4,?Server4),
    TlS4=gen_server:call({server,?Server4},firstTl),
    printTl(MyPanel,Green,Red,Yellow,TlS4,?Server4);
    off->ok end;
%display car's location at the screen%

handle_sync_event(_Event,_,State) ->
  {noreply, State}.

%function that responsible for printing the color of the traffic light%
printTl(_,_,_,_,[],_)->
  ok;
printTl(_,_,_,_,{reply,[],{server_state}},_)->
  ok;
printTl(Panel,Green,Red,Yellow,Tl,ServerN)->
  DC=wxClientDC:new(Panel),
  %io:format("~p~n",[Tl]),
  [{R1,{Jx,Jy},Color}]=Tl,
  ets:insert(traffic_light,{R1,Jx,Jy,Color,ServerN}),
  case Color of
    red->wxDC:drawBitmap(DC,Red,{Jx,Jy});
    green->wxDC:drawBitmap(DC,Green,{Jx,Jy});
    yellowFormRed->wxDC:drawBitmap(DC,Yellow,{Jx,Jy});
    yellowFormGreen->wxDC:drawBitmap(DC,Yellow,{Jx,Jy})
  end,
  [{_,Status}]=ets:lookup(servers,ServerN),
  if
    Status==on-> NextTl=gen_server:call({server,ServerN},{nextTl,R1}),
      printTl(Panel,Green,Red,Yellow,NextTl,ServerN);
    true->nothing end.



%function that responsible to display the right location of the cars%
cars_movement(_,_,_,_,_,[],_)->
  ok;
cars_movement(Panel,RedCarN,RedCarW,RedCarS,RedCarE,Car,ServerN)->
  DC=wxClientDC:new(Panel),
  [{CarNumber1,Road,{Cx,Cy},_Speed,Dir,Color}]=Car,
  %ets:update_element(cars,CarNumber1,[{2,Road},{3,Cx},{4,Cy},{5,Dir}]),
  ets:insert(cars,{CarNumber1,Road,Cx,Cy,Dir,ServerN}),
  %io:format("~p",[ets:lookup(cars,Car)]),
  case Color of
    red->
      case Dir of
        north->
          wxDC:drawBitmap(DC,RedCarN,{Cx,Cy});
        south->
          wxDC:drawBitmap(DC,RedCarS,{Cx,Cy});
        east->
          wxDC:drawBitmap(DC,RedCarE,{Cx,Cy});
        west->
          wxDC:drawBitmap(DC,RedCarW,{Cx,Cy})
      end
  end,
  [{_,Status}]=ets:lookup(servers,ServerN),
  if
    Status==on-> NextCar=gen_server:call({server,ServerN},{nextcar,CarNumber1}),
%  io:format("Nextcar=~p",[NextCar]),
      cars_movement(Panel,RedCarN,RedCarW,RedCarS,RedCarE,NextCar,ServerN);
    true->nothing end.

%function that responsible to make all the sprites ready for use.
createMap()->
  %create Map
  MyMap = wxImage:scale(wxImage:new("nmap.jpg"),?Mx,?My),
  BMap=wxBitmap:new(MyMap),
  wxImage:destroy(MyMap),
  %create cars
  %create redCar
  RedCar=wxImage:scale(wxImage:new("car1.png"),50,30),
  %west
  BRedCarW=wxBitmap:new(RedCar),
  %north
  RedCarN=wxImage:rotate90(RedCar),
  BRedCarN=wxBitmap:new(RedCarN),
  %east
  RedCarE=wxImage:rotate90(RedCarN),
  BRedCarE=wxBitmap:new(RedCarE),
  %south
  RedCarS=wxImage:rotate90(RedCarE),
  BRedCarS=wxBitmap:new(RedCarS),
  wxImage:destroy(RedCar),

  Green=wxImage:scale(wxImage:new("green.jpg"),30,30),
  BGreen=wxBitmap:new(Green),
  wxImage:destroy(Green),

  Red=wxImage:scale(wxImage:new("red.jpg"),30,30),
  Bred=wxBitmap:new(Red),
  wxImage:destroy(Red),

  Yellow=wxImage:scale(wxImage:new("yellow.jpg"),30,30),
  Byellow=wxBitmap:new(Yellow),
  wxImage:destroy(Yellow),


  {BMap,BRedCarW,BRedCarN,BRedCarE,BRedCarS,BGreen,Bred,Byellow}.

%if the server is down, move the cars to different pc%
moveCarsToOtherPc(_PC_down,_PcToMove,[])->ok;
moveCarsToOtherPc(_PC_down,_PcToMove,'$end_of_table')->ok;
moveCarsToOtherPc(PC_down,PcToMove,CarToMove)->[{CarNumber1,Road1,Cx1,Cy1,Dir1,Server}]=CarToMove,
  if
    Server==PC_down->  gen_server:cast({server,PcToMove},{start_car,CarNumber1,Cx1,Cy1,Dir1,Road1}),NextCar=ets:lookup(cars,ets:next(cars,CarNumber1)),moveCarsToOtherPc(PC_down,PcToMove,NextCar);
    true->moveCarsToOtherPc(PC_down,PcToMove,ets:lookup(cars,ets:next(cars,CarNumber1)))
  end.

%if the server is down, move the traffic lights to different pc%
moveTrafficLightToOtherPc(Counter,_PC_down,_PcToMove,[])->ets:update_element(traffic_light_number,number,[{2,Counter}]),ok;
moveTrafficLightToOtherPc(Counter,_PC_down,_PcToMove,'$end_of_table')->ets:update_element(traffic_light_number,number,[{2,Counter}]),ok;
moveTrafficLightToOtherPc(Counter,PC_down,PcToMove,TrafficToMOve)->[{Road,X,Y,Color,Server}]=TrafficToMOve,
  if
    Server==PC_down->Name=makeAnAtom(Counter,k),gen_server:cast({server,PcToMove},{start_traffic_light,Road,X,Y,Color,Name}),moveTrafficLightToOtherPc(Counter+1,PC_down,PcToMove,ets:lookup(traffic_light,ets:next(traffic_light,Road)));
    true->_Name=makeAnAtom(Counter,k),moveTrafficLightToOtherPc(Counter,PC_down,PcToMove,ets:lookup(traffic_light,ets:next(traffic_light,Road)))
  end.

%if the server is down, move the junction to different pc%
moveJunctionToOtherpc(_PC_down,_PcToMove,[])->ok;
moveJunctionToOtherpc(_,_,'$end_of_table')->ok;
moveJunctionToOtherpc(PC_down,PcToMove,JuncToMOve)->[{{X,Y},Listin,ListOut,ListDir,Server}]=JuncToMOve,
  if
    Server==PC_down->   gen_server:cast({server,PcToMove},{start_junc,{X,Y},Listin,ListOut,ListDir}),io:format("~p",[PC_down]),moveJunctionToOtherpc(PC_down,PcToMove,ets:lookup(junction,ets:next(junction,{X,Y})));
    true->moveJunctionToOtherpc(PC_down,PcToMove,ets:lookup(junction,ets:next(junction,{X,Y}))) end.

%check to which pc we can give the data of the fallen computer%
checkWichBackupIsALIVE(PC_down,PcToMove)->[{_,Counter}]=ets:lookup(traffic_light_number,number),[{_,Status}]=ets:lookup(servers,PcToMove),if Status==off->io:format("~p",[PC_down]),checkWichBackupIsALIVE(PC_down,ets:next(servers,PcToMove));
                                                                                                                                            true->moveCarsToOtherPc(PC_down,PcToMove,ets:lookup(cars,ets:first(cars))),
                                                                                                                                              moveTrafficLightToOtherPc(Counter,PC_down,PcToMove,ets:lookup(traffic_light,ets:first(traffic_light))),
                                                                                                                                              moveJunctionToOtherpc(PC_down,PcToMove,ets:lookup(junction,ets:first(junction))) end.
%check with monitor if pc is down%
check_PC(PC_to_check) ->erlang:monitor_node(PC_to_check, true),
  receive
    {nodedown,_}-> ets:update_element(servers,PC_to_check,[{2,off}]),
      gen_server:cast({server,?Server1},{server_down,PC_to_check}),
      gen_server:cast({server,?Server2},{server_down,PC_to_check}),
      gen_server:cast({server,?Server3},{server_down,PC_to_check}),
      gen_server:cast({server,?Server4},{server_down,PC_to_check})
      ,checkWichBackupIsALIVE(PC_to_check,ets:first(servers)) end.



%gen_server:cast({server,?Server3},{start_car,shaar,645,900,north,22}),
%create_cars([],0)->
% none;
%create_cars(_Data,0)->
%  none;
%create_cars(Data,Number)->
%  {Car,X,Y,Dir,Road,Server}=hd(Data),
%  gen_server:cast({server,Server},{start_car,Car,X,Y,Dir,Road}),
% create_cars(tl(Data),Number-1).

%function that responsible of gathering information for stats%
add_last([],NewList)->
  NewList;
add_last([H|T],NewList) ->
  {Car,TimerD,TimerS,Drive,Stop}=H,
  if
    (TimerS==0) and (TimerD=/=0)->
      New_Time=timer:now_diff(erlang:timestamp(),TimerD),
      List=lists:append(NewList,[{Car,Drive+New_Time,Stop}]),
      add_last(T,List);
    (TimerD==0)  and (TimerS=/=0)->
      New_Time=timer:now_diff(erlang:timestamp(),TimerS),
      List=lists:append(NewList,[{Car,Drive,Stop+New_Time}]),
      add_last(T,List);
    true->
      List=lists:append(NewList,[{Car,Drive,Stop}]),
      add_last(T,List)
  end.
%create the stats and display it to user%
create_Stats([],DriveSum,StopSum,Counter)->
  PrecentD=DriveSum/(DriveSum+StopSum)*100,
  PrecentS=100-PrecentD,
  AvgD=DriveSum/Counter,
  AvgS=StopSum/Counter,
  AvgSpeed=(AvgD)*20/((AvgD+AvgS)),
  io:format("Cars Avg time driving:~p seconds~n",[AvgD/1000000]),
  io:format("Cars Avg time stopping:~p seconds~n",[AvgS/1000000]),
  io:format("Cars driving time in precentage:~p%~n",[PrecentD]),
  io:format("Cars stopping time in precentage:~p%~n",[PrecentS]),
  io:format("Cars Avg speed:~p meter/second~n",[AvgSpeed]);
create_Stats([H|T],DriveSum,StopSum,Counter)->
  {_Cname,Drive,Stop}=H,
  create_Stats(T,DriveSum+Drive,Stop+StopSum,Counter+1).


makeAnAtom(X,Name)->list_to_atom(string:join([atom_to_list(Name),integer_to_list(X)],"")).
