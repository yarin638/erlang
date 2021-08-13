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

-export([start/0,init/1,handle_event/2,handle_info/2,handle_sync_event/3]).
-define(Mx,781).
-define(My,1024).
-define(Timer,67).
-record(state,{frame, panel, paint,map,redcarn,redcarw,redcare,redcars,bluecarn,bluecarw,bluecare,bluecars}).


start() ->
  wx_object:start({local,?SERVER},?MODULE,[],[]).

init([])->
  net_kernel:connect_node(?Server1),
  net_kernel:connect_node(?Server2),
  net_kernel:connect_node(?Server3),
  net_kernel:connect_node(?Server4),
  rpc:call(?Server1,server,start_link,[]),
  rpc:call(?Server2,server,start_link,[]),
  rpc:call(?Server3,server,start_link,[]),
  rpc:call(?Server4,server,start_link,[]),
  %%start traffic_light%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  gen_server:cast({server,?Server1},{start_traffic_light,1,120,95,red,t1}),
  gen_server:cast({server,?Server1},{start_traffic_light,2,175,40,green,t2}),
  gen_server:cast({server,?Server4},{start_traffic_light,4,340,95,red,t3}),
  gen_server:cast({server,?Server4},{start_traffic_light,5,395,160,green,t4}),
  gen_server:cast({server,?Server4},{start_traffic_light,6,590,95,green,t5}),
  gen_server:cast({server,?Server4},{start_traffic_light,7,645,150,red,t6}),
  gen_server:cast({server,?Server4},{start_traffic_light,10,340,345,red,t18}),
  gen_server:cast({server,?Server4},{start_traffic_light,35,395,290,green,t19}),
  gen_server:cast({server,?Server2},{start_traffic_light,13,120,520,red,t7}),
  gen_server:cast({server,?Server2},{start_traffic_light,9,175,465,green,t8}),
  gen_server:cast({server,?Server3},{start_traffic_light,14,350,520,red,t10}),
  gen_server:cast({server,?Server3},{start_traffic_light,15,405,465,green,t11}),
  gen_server:cast({server,?Server3},{start_traffic_light,18,590,635,red,t12}),
  gen_server:cast({server,?Server3},{start_traffic_light,25,590,680,green,t13}),
  gen_server:cast({server,?Server3},{start_traffic_light,22,645,815,red,t14}),
  gen_server:cast({server,?Server3},{start_traffic_light,25,700,760,green,t15}),
  gen_server:cast({server,?Server2},{start_traffic_light,12,80,745,red,t16}),
  gen_server:cast({server,?Server2},{start_traffic_light,19,135,800,green,t17}),
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %%start junc%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  gen_server:cast({server,?Server1},{start_junc,{175,95},[1,2],[3,4],[south,east]}),
  gen_server:cast({server,?Server4},{start_junc,{395,95},[4,5],[6],[east]}),
  gen_server:cast({server,?Server4},{start_junc,{645,95},[6,7],[8],[north]}),
  gen_server:cast({server,?Server1},{start_junc,{175,345},[3],[9,10],[south,east]}),
  gen_server:cast({server,?Server4},{start_junc,{395,345},[10,35],[15],[south]}),
  gen_server:cast({server,?Server2},{start_junc,{175,520},[9,13],[14],[east]}),
  gen_server:cast({server,?Server3},{start_junc,{405,520},[14,15],[16],[south]}),
  gen_server:cast({server,?Server3},{start_junc,{395,635},[16],[17,18],[south,east]}),
  gen_server:cast({server,?Server3},{start_junc,{645,635},[18,24],[26],[north]}),
  gen_server:cast({server,?Server3},{start_junc,{645,520},[26],[27,34],[east,north]}),
  gen_server:cast({server,?Server3},{start_junc,{645,760},[22,25],[24],[north]}),
  gen_server:cast({server,?Server2},{start_junc,{80,800},[12,19],[32],[west]}),
  gen_server:cast({server,?Server2},{start_junc,{80,520},[11],[12,13],[south,east]}),
  gen_server:cast({server,?Server3},{start_junc,{405,800},[17],[19,20],[west,south]}),
  gen_server:cast({server,?Server4},{start_junc,{645,220},[34],[33,7],[west,north]}),
  gen_server:cast({server,?Server4},{start_junc,{395,220},[33],[35,5],[south,north]}),
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %%%%start cars%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  gen_server:cast({server,?Server1},{start_car,yarin,175,10,south,2}),
  gen_server:cast({server,?Server4},{start_car,lotke,550,95,east,6}),
  gen_server:cast({server,?Server2},{start_car,elioz,0,520,east,11}),
  gen_server:cast({server,?Server4},{start_car,eliav,480,95,east,6}),
  gen_server:cast({server,?Server4},{start_car,yanir,450,220,west,33}),
 % gen_server:cast({server,?Server3},{start_car,meitar,570,635,east,18}),
  %gen_server:cast({server,?Server1},{start_car,tal,300,95,east,4}),
  %gen_server:cast({server,?Server1},{start_car,daniela,200,345,east,10}),
  %gen_server:cast({server,?Server3},{start_car,naema,320,520,east,14}),
 % gen_server:cast({server,?Server3},{start_car,raviv,405,430,south,15}),
%  gen_server:cast({server,?Server1},{start_car,hadar,175,250,south,3}),
  %en_server:cast({server,?Server4},{start_car,shahar,645,850,north,130}),
  gen_server:cast({server,?Server4},{start_car,shaar,645,900,north,22}),
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  WxServer=wx:new(),
  MyFrame=wxFrame:new(WxServer,123,"TrafficMap",[{size,{?Mx,?My}}]),
  MyPanel=wxPanel:new(MyFrame),
  {Map,RedCarW,RedCarN,RedCarE,RedCarS,BlueCarW,BlueCarN,BlueCarE,BlueCarS}=createMap(),
  wxFrame:show(MyFrame),
  wxPanel:connect(MyPanel, paint, [callback]),
  wxFrame:connect(MyFrame, close_window),
  erlang:send_after(?Timer,self(),timer),
  {MyFrame,#state{frame=MyFrame,panel=MyPanel,map=Map,redcarn=RedCarN,redcarw=RedCarW,redcare=RedCarE,redcars=RedCarS,bluecarn=BlueCarN,bluecarw=BlueCarW,bluecare=BlueCarE,bluecars=BlueCarS}}.

handle_info(timer, State=#state{frame = Frame}) ->  % refresh screen for graphics
  wxWindow:refresh(Frame), % refresh screen
  erlang:send_after(?Timer,self(),timer),
  {noreply, State};

handle_info({nodeup,PC},State)->
  io:format("~p nodeup ~n",[PC]),
  {noreply, State}.



handle_event(#wx{event = #wxClose{}},State = #state {frame = Frame}) -> % close window event
  io:format("Exiting\n"),
  wxWindow:destroy(Frame),
  wx:destroy(),
  {stop,normal,State}.

handle_sync_event(#wx{event=#wxPaint{}}, _,  _State = #state{panel=MyPanel,map=Map,redcarn=RedCarN,redcarw=RedCarW,redcare=RedCarE,redcars=RedCarS,bluecarn=BlueCarN,bluecarw=BlueCarW,bluecare=BlueCarE,bluecars=BlueCarS})->
  DC=wxPaintDC:new(MyPanel),
 % io:format("Shalom\n"),
  wxDC:clear(DC),
  wxDC:drawBitmap(DC,Map,{0,0}),
  %wxDC:drawBitmap(DC,RedCarE,{1,1}),
  CarS1=gen_server:call({server,?Server1},firstcar),
  CarS2=gen_server:call({server,?Server2},firstcar),
  CarS3=gen_server:call({server,?Server3},firstcar),
  CarS4=gen_server:call({server,?Server4},firstcar),
  cars_movement(MyPanel,RedCarN,RedCarW,RedCarS,RedCarE,BlueCarN,BlueCarW,BlueCarS,BlueCarE,CarS1,?Server1),
  cars_movement(MyPanel,RedCarN,RedCarW,RedCarS,RedCarE,BlueCarN,BlueCarW,BlueCarS,BlueCarE,CarS2,?Server2),
  cars_movement(MyPanel,RedCarN,RedCarW,RedCarS,RedCarE,BlueCarN,BlueCarW,BlueCarS,BlueCarE,CarS3,?Server3),
  cars_movement(MyPanel,RedCarN,RedCarW,RedCarS,RedCarE,BlueCarN,BlueCarW,BlueCarS,BlueCarE,CarS4,?Server4);


handle_sync_event(_Event,_,State) ->
  {noreply, State}.

cars_movement(_,_,_,_,_,_,_,_,_,[],_)->
  ok;
cars_movement(Panel,RedCarN,RedCarW,RedCarS,RedCarE,BlueCarN,BlueCarW,BlueCarS,BlueCarE,Car,ServerN)->
  DC=wxClientDC:new(Panel),
  [{CarNumber1,_Road,{Cx,Cy},_Speed,Dir,Color}]=Car,
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
      end;
    blue->
      case Dir of
        north->
          wxDC:drawBitmap(DC,BlueCarN,{Cx,Cy});
        south->
          wxDC:drawBitmap(DC,BlueCarS,{Cx,Cy});
        east->
          wxDC:drawBitmap(DC,BlueCarE,{Cx,Cy});
        west->
          wxDC:drawBitmap(DC,BlueCarW,{Cx,Cy})
      end
  end,
  NextCar=gen_server:call({server,ServerN},{nextcar,CarNumber1}),
%  io:format("Nextcar=~p",[NextCar]),
  cars_movement(Panel,RedCarN,RedCarW,RedCarS,RedCarE,BlueCarN,BlueCarW,BlueCarS,BlueCarE,NextCar,ServerN).

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

  %blue
  BlueCar=wxImage:scale(wxImage:new("carb.png"),50,30),
  %west
  BBlueCarW=wxBitmap:new(BlueCar),
  %north
  BlueCarN=wxImage:rotate90(BlueCar),
  BBlueCarN=wxBitmap:new(BlueCarN),
  %east
  BlueCarE=wxImage:rotate90(BlueCarN),
  BBlueCarE=wxBitmap:new(BlueCarE),
  %south
  BlueCarS=wxImage:rotate90(BlueCarE),
  BBlueCarS=wxBitmap:new(BlueCarS),
  wxImage:destroy(BlueCar),
  {BMap,BRedCarW,BRedCarN,BRedCarE,BRedCarS,BBlueCarW,BBlueCarN,BBlueCarE,BBlueCarS}.