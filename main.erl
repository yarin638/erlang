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

-behaviour(wx_object).
-include_lib("wx/include/wx.hrl").
-define(SERVER, ?MODULE).

-export([start/0,init/1,handle_event/2,handle_sync_event/3]).
-define(Mx,1344).
-define(My,890).
-record(state,{frame, panel, paint,map,redcarn,redcarw,redcare,redcars,bluecarn,bluecarw,bluecare,bluecars}).


start() ->
  wx_object:start({local,?SERVER},?MODULE,[],[]).

init([])->
  WxServer=wx:new(),
  MyFrame=wxFrame:new(WxServer,123,"TrafficMap",[{size,{?Mx,?My}}]),
  MyPanel=wxPanel:new(MyFrame),
  {Map,RedCarW,RedCarN,RedCarE,RedCarS,BlueCarW,BlueCarN,BlueCarE,BlueCarS}=createMap(),
  wxFrame:show(MyFrame),
  wxPanel:connect(MyPanel, paint, [callback]),
  wxFrame:connect(MyFrame, close_window),
  {MyFrame,#state{frame=MyFrame,panel=MyPanel,map=Map,redcarn=RedCarN,redcarw=RedCarW,redcare=RedCarE,redcars=RedCarS,bluecarn=BlueCarN,bluecarw=BlueCarW,bluecare=BlueCarE,bluecars=BlueCarS}}.


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
  cars_movement(MyPanel,RedCarN,RedCarW,RedCarE,RedCarS,BlueCarN,BlueCarW,BlueCarE,BlueCarS,ets:first(cars));

handle_sync_event(_Event,_,State) ->
  {noreply, State}.

cars_movement(_,_,_,_,_,_,_,_,_,'$end_of_table')->
  none;
cars_movement(Panel,RedCarN,RedCarW,RedCarS,RedCarE,BlueCarN,BlueCarW,BlueCarS,BlueCarE,Car)->
  DC=wxClientDC:new(Panel),
  [{_CarNumber1,_Road,{Cx,Cy},_Speed,Dir,Color}]=ets:lookup(cars,Car),
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
  cars_movement(Panel,RedCarN,RedCarW,RedCarS,RedCarE,BlueCarN,BlueCarW,BlueCarS,BlueCarE,ets:next(cars,Car)).

createMap()->
  %create Map
  MyMap = wxImage:scale(wxImage:new("rmap.jpg"),?Mx,?My),
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