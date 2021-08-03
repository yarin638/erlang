%%%-------------------------------------------------------------------
%%% @author eliav
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. אוג׳ 2021 13:18
%%%-------------------------------------------------------------------
-module('Alerts').
-author("eliav").

%% API
-export([tl_alert/2,car_alert/2]).
car_alert(Car,'$end_of_table')->
  car_alert(Car,ets:first:(cars));

car_alert(Car,P_car)->
  [_CarNumber1,Road1,{Cx1,Cy1},_Speed1,_Dir1,_Color1]=ets:lookup(cars,Car), %get car details
  Alive=ets:member(cars,P_car),
  if
    Alive=:=true->
      [_CarNumber2,Road2,{Cx2,Cy2},Speed2,Dir2,_Color2]=ets:lookup(cars,P_car);
    true->
      [_CarNumber2,Road2,{Cx2,Cy2},Speed2,Dir2,_Color2]=ets:lookup(cars,ets:first(cars))
  end,
  case Road1==Road2 of
    true->
      case Road1 of
        north->
          if
            Cy2-Cy1<25 and Cy2-Cy1>0 ->
              cars:close:car_alert(Car,P_car),
              timer:sleep(500),
              car_alert(Car,ets:first(cars));
            true->
              car_alert(Car,ets:next(cars,P_car))
          end;
        south->
          if
            Cy1-Cy2<25 and Cy1-Cy2>0 ->
              cars:close:car_alert(Car,P_car),
              timer:sleep(500),
              car_alert(Car,ets:first(cars));
            true->
              car_alert(Car,ets:next(cars,P_car))
          end;
        west->
          if
            Cx1-Cx2<25 and Cx1-Cx2>0 ->
              cars:close:car_alert(Car,P_car),
              timer:sleep(500),
              car_alert(Car,ets:first(cars));
            true->
              car_alert(Car,ets:next(cars,P_car))
          end;
        east->
          if
            Cx1-Cx2<25 and Cx1-Cx2>0 ->
              cars:close:car_alert(Car,P_car),
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
  [_CarNumber,Road,{Cx,Cy},Speed,Dir,_Color]=ets:lookup(cars,Car), %get car details
  [{R1,R2},{Jx,Jy},TLPid]=ets:lookup(traffic_light,Junction), %get first junction details
  case Road==R1 orelse Road==R2 of %if the car is on the same road of the junction
    true-> %same road
      case Dir of
        north-> %car is moving north
          case Jy-Cy<25 and Jy-Cy>0 of   %check if car is near the junction, and didn't already passed it.
            true->
              cars:tl_alert(Car,sys:get_state(TLPid)),
              timer:sleep(1500),
              tl_alert(Car,ets:first(traffic_light));
            _->
              tl_alert(Car,ets:next(traffic_light,Junction))
          end;
        south-> %car is moving north
          case Cy-Jy<25 and Cy-Jy>0 of   %check if car is near the junction, and didn't already passed it.
            true->
              cars:tl_alert(Car,sys:get_state(TLPid)),
              timer:sleep(1500),
              tl_alert(Car,ets:first(traffic_light));
            _->
              tl_alert(Car,ets:next(traffic_light,Junction))
          end;
        west-> %car is moving north
          case Cx-Jx<25 and Cx-Jx>0 of   %check if car is near the junction, and didn't already passed it.
            true->
              cars:tl_alert(Car,sys:get_state(TLPid)),
              timer:sleep(1500),
              tl_alert(Car,ets:first(traffic_light));
            _->
              tl_alert(Car,ets:next(traffic_light,Junction))
          end;
        east-> %car is moving north
          case Jx-Cx<25 and Jx-Cx>0 of   %check if car is near the junction, and didn't already passed it.
            true->
              cars:tl_alert(Car,sys:get_state(TLPid)),
              timer:sleep(1500),
              tl_alert(Car,ets:first(traffic_light));
            _->
              tl_alert(Car,ets:next(traffic_light,Junction))
          end
      end;
    false->
      tl_alert(Car,ets:next(traffic_light,Junction))
  end.







