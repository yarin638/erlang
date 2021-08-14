%%%-------------------------------------------------------------------
%%% @author eliav
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. אוג׳ 2021 13:18
%%%-------------------------------------------------------------------
-module('alerts').
-author("eliav").
-define(X_center,270).
-define(Y_center,390).

%% API
-export([out_of_map/1,tl_alert/2,car_alert/2,junc_alert/2,clear_path/2,switch_area/4]).

out_of_map(Car)-> %check if Car is out of map.
  [_CarNumber1,_Road1,{X1,Y1},_Speed,_Dir1,_Color]=ets:lookup(cars,Car),
  if
    (X1>1000) or (X1<0) or (Y1>1000) or (Y1<0) ->
      cars:out_of_map(Car);
    true->
      out_of_map(Car)
  end.

junc_alert(Car,'$end_of_table')-> %check if car is close to junction
  junc_alert(Car,ets:first(junction));
junc_alert(Car,Junction)->
  Bool2=ets:member(cars,Car),
  case ets:member(cars,Car) of false-> ok;
    true->
  [{_CarNumber1,Road,{Cx,Cy},_Speed,Dir,_Color}]=ets:lookup(cars,Car), %car details
  [{{Jx,Jy},RoadListin,RoadListout,DirList}]=ets:lookup(junction,Junction), %junction details
  Bool=lists:member(Road,RoadListin), %check if the car is on the same road as the junction
  case Bool of
    false->
      junc_alert(Car,ets:next(junction,Junction)); %if not, check next junction
    true->
      NewDir=turn_where(Dir,DirList), %if it does, decide to where it should turn, even if it not close to the junction.
      NewRoad=find_road(NewDir,DirList,RoadListout),
      case Dir of
        south-> %car is moving north
          case (Jy-Cy<5) and (Jy-Cy>0) of   %check if car is near the junction, and didn't already passed it.
            true->
              cars:junc_alert(Car,NewDir,NewRoad), %send event
              timer:sleep(1000),
              junc_alert(Car,ets:first(junction));
            false->
              junc_alert(Car,ets:next(junction,Junction))
          end;
        north-> %car is moving north
          case (Cy-Jy<5) and(Cy-Jy>0) of   %check if car is near the junction, and didn't already passed it.
            true->
              cars:junc_alert(Car,NewDir,NewRoad), %send event
              timer:sleep(1000),
              junc_alert(Car,ets:first(junction));
            false->
              junc_alert(Car,ets:next(junction,Junction))
          end;
        west-> %car is moving north
          case (Cx-Jx<5) and (Cx-Jx>0) of   %check if car is near the junction, and didn't already passed it.
            true->
              cars:junc_alert(Car,NewDir,NewRoad), %send event
              timer:sleep(1000),
              junc_alert(Car,ets:first(junction));
            false->
              junc_alert(Car,ets:next(junction,Junction))
          end;
        east-> %car is moving north
          case (Jx-Cx<5) and (Jx-Cx>0) of   %check if car is near the junction, and didn't already passed it.
            true->
              cars:junc_alert(Car,NewDir,NewRoad), %send event
              timer:sleep(1000),
              junc_alert(Car,ets:first(junction));
            false->
              junc_alert(Car,ets:next(junction,Junction))
          end
      end
  end
  end.
  
clear_path(Car,Close_Car)->
  [{_CarNumber1,_Road1,{Cx1,Cy1},_Speed,Dir1,_Color}]=ets:lookup(cars,Car), %Car details
  Bool=ets:member(cars,Close_Car),
  if Bool==true->
       [{_CarNumber2,_Road2,{Cx2,Cy2},_Speed,_Dir2,_Color}]=ets:lookup(cars,Close_Car),
  case Dir1 of
    south->
      if
        (Cy2-Cy1>70) and (Cy2-Cy1>0) ->
          cars:clear_path(Car);
        true->
          timer:sleep(50),
          clear_path(Car,Close_Car)
      end;
    north->
      if
        (Cy1-Cy2>70) and (Cy1-Cy2>0) ->
          cars:clear_path(Car);
        true->
          timer:sleep(50),
          clear_path(Car,Close_Car)
      end;
    west->
      if
        (Cx1-Cx2>70 )and( Cx1-Cx2>0) ->
          cars:clear_path(Car);
          true->
            timer:sleep(50),
            clear_path(Car,Close_Car)
          end;
    east->
      if
        (Cx2-Cx1>70) and (Cx1-Cx2>0 )->
          cars:clear_path(Car);
        true->
          timer:sleep(50),
          clear_path(Car,Close_Car)
      end
  end;
  true->cars:clear_path(Car)
  end.

car_alert(Car,'$end_of_table')->
  car_alert(Car,ets:first(cars));

car_alert(Car,P_car)->
  [{CarNumber1,Road1,{Cx1,Cy1},_Speed1,_Dir1,_Color1}]=ets:lookup(cars,Car), %get car details
  Alive=ets:member(cars,P_car),
  if
    Alive=:=true->
      [{CarNumber2,Road2,{Cx2,Cy2},Speed2,Dir2,_Color2}]=ets:lookup(cars,P_car);
    true->
      [{CarNumber2,Road2,{Cx2,Cy2},Speed2,Dir2,_Color2}]=ets:lookup(cars,ets:first(cars))
  end,
  case (Road1==Road2) and(CarNumber1=/=CarNumber2) of
    true->
      case _Dir1 of
        south->
          if
            (Cy2-Cy1<50) and (Cy2-Cy1>0 )->
              cars:car_alert(Car,P_car),
	      timer:sleep(500),
              car_alert(Car,ets:first(cars));
            true->
              car_alert(Car,ets:next(cars,P_car))
          end;
        north->
          if
            (Cy1-Cy2<50 )and( Cy1-Cy2>0 )->
              cars:car_alert(Car,P_car),
	      timer:sleep(500),
              car_alert(Car,ets:first(cars));
            true->
              car_alert(Car,ets:next(cars,P_car))
          end;
        west->
          if
            (Cx1-Cx2<50) and (Cx1-Cx2>0) ->
              cars:car_alert(Car,P_car),
	      timer:sleep(500),
              car_alert(Car,ets:first(cars));
            true->
              car_alert(Car,ets:next(cars,P_car))
          end;
        east->
          if
            (Cx2-Cx1<50) and( Cx2-Cx1>0 )->
              cars:car_alert(Car,P_car),
              timer:sleep(500),
              car_alert(Car,ets:first(cars));
            true->
              car_alert(Car,ets:next(cars,P_car))
          end
      end;
    false->
      car_alert(Car,ets:next(cars,P_car))
  end.


tl_alert(Car,'$end_of_table')-> % start
  tl_alert(Car,ets:first(traffic_light));

tl_alert(Car,Junction)->
  case ets:member(cars,Car) of false->
      ok;
    true->
  [{_CarNumber,Road,{Cx,Cy},_Speed,Dir,_Color}]=ets:lookup(cars,Car), %get car details
  [{R1,{Jx,Jy},TLPid}]=ets:lookup(traffic_light,Junction), %get first junction details
  case Road==R1  of %if the car is on the same road of the junction
    true-> %same road
      case Dir of
        south-> %car is moving north
          case (Jy-Cy<25) and (Jy-Cy>0) of   %check if car is near the junction, and didn't already passed it.
            true->
              {Color,0}=sys:get_state(TLPid),
              cars:tl_alert(Car,Color),
              timer:sleep(200),
              tl_alert(Car,ets:first(traffic_light));
            _->
              tl_alert(Car,ets:next(traffic_light,Junction))
          end;
        north-> %car is moving north
          case (Cy-Jy<25) and (Cy-Jy>0) of   %check if car is near the junction, and didn't already passed it.
            true->
              {Color,0}=sys:get_state(TLPid),
              cars:tl_alert(Car,Color),
              timer:sleep(200),
              tl_alert(Car,ets:first(traffic_light));
            _->
              tl_alert(Car,ets:next(traffic_light,Junction))
          end;
        west-> %car is moving north
          case (Cx-Jx<25) and (Cx-Jx>0 )of   %check if car is near the junction, and didn't already passed it.
            true->
              {Color,0}=sys:get_state(TLPid),
              cars:tl_alert(Car,Color),
              timer:sleep(200),
              tl_alert(Car,ets:first(traffic_light));
            _->
              tl_alert(Car,ets:next(traffic_light,Junction))
          end;
        east-> %car is moving north
          case (Jx-Cx<25) and (Jx-Cx>0) of   %check if car is near the junction, and didn't already passed it.
            true->
              {Color,0}=sys:get_state(TLPid),
              cars:tl_alert(Car,Color),
              timer:sleep(200),
              tl_alert(Car,ets:first(traffic_light));
            _->
              tl_alert(Car,ets:next(traffic_light,Junction))
          end
      end;
    false->
      tl_alert(Car,ets:next(traffic_light,Junction))
  end
  end.


switch_area(Car,SensorPid,SensorPid2,SensorPid3)->
  [{_CarNumber,_Road,{Cx,Cy},_Speed,Dir,_Color}]=ets:lookup(cars,Car),
  case Dir of
    south->
      if
        Cx<?X_center , Cy<?Y_center , (?Y_center-Cy)<2->
          link(SensorPid),link(SensorPid2),link(SensorPid3),
          cars:switch_area(Car,server2),
          timer:sleep(1000);
        Cx>?X_center ,Cy<?Y_center,(?Y_center-Cy)<2->
          link(SensorPid),link(SensorPid2),link(SensorPid3),
          cars:switch_area(Car,server3),
          timer:sleep(300);
        true->
          switch_area(Car,SensorPid,SensorPid2,SensorPid3)
      end;
    north->
      if
        Cx<?X_center , Cy>?Y_center,(Cy-?Y_center)<5->
          link(SensorPid),link(SensorPid2),link(SensorPid3),
          cars:switch_area(Car,server1),
          timer:sleep(1000);
        Cx>?X_center,Cy>?Y_center , (Cy-?Y_center)==5->
          %io:format("move to 4"),
          %io:format("linked"),
          cars:switch_area(Car,server4),
          timer:sleep(300);
        true->
          switch_area(Car,SensorPid,SensorPid2,SensorPid3)
      end;
    east->
      if
        Cx<?X_center,Cy>?Y_center,(?X_center-Cx)<2->
          link(SensorPid),link(SensorPid2),link(SensorPid3),
          cars:switch_area(Car,server3),
          timer:sleep(1000);
        Cx<?X_center , Cy<?Y_center,(?X_center-Cx)<2 ->
          link(SensorPid),link(SensorPid2),link(SensorPid3),
          cars:switch_area(Car,server4),
          timer:sleep(300);
        true->
          switch_area(Car,SensorPid,SensorPid2,SensorPid3)
      end;
    west->
      if
        Cx>?X_center,Cy>?Y_center,(Cx-?X_center)<2->
          link(SensorPid),link(SensorPid2),link(SensorPid3),
          cars:switch_area(Car,server2),
          timer:sleep(1000);
        Cx>?X_center,Cy<?Y_center,(Cx-?X_center)<2->
          link(SensorPid),link(SensorPid2),link(SensorPid3),
          cars:switch_area(Car,server1),
          timer:sleep(300);
        true->
          switch_area(Car,SensorPid,SensorPid2,SensorPid3)
      end
  end.

%%%%%%%subfunc

%counter([_|T],Num)->counter(T,Num+1);
%counter([],Num)->Num.


turn_where(west,Dirlist)->
  turn_where(lists:delete(east,Dirlist));
turn_where(south,Dirlist)->
  turn_where(lists:delete(north,Dirlist));
turn_where(east,Dirlist)->
  turn_where(lists:delete(west,Dirlist));
turn_where(north,Dirlist)->
  turn_where(lists:delete(south,Dirlist)).
turn_where(DirList)->
  Num=length(DirList),
  DtoUse=rand:uniform(Num),
  lists:nth(DtoUse,DirList).

find_road(Elem,Dirlist,RoadList)->
  Ind=index_of(Elem,Dirlist),
  lists:nth(Ind,RoadList).

index_of(Item, List) -> index_of(Item, List, 1).
index_of(_, [], _)  -> not_found;
index_of(Item, [Item|_], Index) -> Index;
index_of(Item, [_|Tl], Index) -> index_of(Item, Tl, Index+1).
