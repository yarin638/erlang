%%%-------------------------------------------------------------------
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
-define(SERVER, ?MODULE).

-export([start/0,init/1]).
-define(Mx,1000).
-define(My,1000).
-record(state,{frame, panel, dc, paint,map}).


start() ->
  wx_object:start({local,?SERVER},?MODULE,[],[]).
%% API
init([])->
  WxServer=wx:new(),
  MyFrame=wxFrame:new(WxServer,123,"TrafficMap",[{size,?Mx,?My}]),
  MyPanel=wxPanel:new(MyFrame),
  PaintDC=wxPaintDC:new(MyPanel),
  Buffered=wxBufferedPaintDC(PaintDC),
  Map=createMap(),
  wxframe:show(MyFrame),
  wxPanel:connect(MyPanel, paint, [callback]),
  wxPanel:connect (MyPanel, left_down),
  wxPanel:connect (MyPanel, right_down),
  wxFrame:connect(MyFrame, close_window),
  {MyFrame,#state{frame=MyFrame,panel=MyPanel,dc=PaintDC,paint=Buffered,map=Map}}.

createMap()->
  %create Map
  MyMap = wxImage:scale(wxImage:new("rmap.jpg"),{?Mx,?My}),
  BMap=wxBitmap:new(MyMap),
  wxImage:destroy(MyMap),
  BMap.






