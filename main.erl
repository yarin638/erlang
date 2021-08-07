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
-record(state,{frame, panel, paint,map,car1}).


start() ->
  wx_object:start({local,?SERVER},?MODULE,[],[]).

init([])->
  WxServer=wx:new(),
  MyFrame=wxFrame:new(WxServer,123,"TrafficMap",[{size,{?Mx,?My}}]),
  MyPanel=wxPanel:new(MyFrame),
  % PaintDC=wxPaintDC:new(MyPanel),
  % Buffered=wxBufferedPaintDC:new(MyPanel),
  {Map,Car1}=createMap(),
  wxFrame:show(MyFrame),
  wxPanel:connect(MyPanel, paint, [callback]),
  % wxPanel:connect (MyPanel, left_down),
  % wxPanel:connect (MyPanel, right_down),
  wxFrame:connect(MyFrame, close_window),
  % {MyFrame,#state{frame=MyFrame,panel=MyPanel,dc=PaintDC,paint=Buffered,map=Map}}.
  {MyFrame,#state{frame=MyFrame,panel=MyPanel,map=Map,car1=Car1}}.

createMap()->
  %create Map
  MyMap = wxImage:scale(wxImage:new("rmap.jpg"),?Mx,?My),
  BMap=wxBitmap:new(MyMap),
  wxImage:destroy(MyMap),
  %create cars
  Car1=wxImage:scale(wxImage:new("car1.png"),50,30),
  BCar1=wxBitmap:new(Car1),
  wxImage:destroy(Car1),
  {BMap,BCar1}.



handle_event(#wx{event = #wxClose{}},State = #state {frame = Frame}) -> % close window event
  io:format("Exiting\n"),
  wxWindow:destroy(Frame),
  wx:destroy(),
  {stop,normal,State}.

handle_sync_event(#wx{event=#wxPaint{}}, _,  _State = #state{panel=MyPanel,map=Map,car1=Car1})->
  DC2=wxPaintDC:new(MyPanel),
  io:format("Shalom\n"),
  wxDC:clear(DC2),
  wxDC:drawBitmap(DC2,Map,{0,0}),
  wxDC:drawBitmap(DC2,Car1,{1,1});


handle_sync_event(_Event,_,State) ->
  {noreply, State}.
