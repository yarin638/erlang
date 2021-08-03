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
-export([tl_alert/2]).
car_alert(Car,'$end_of_table')->
  car_alert(Car,ets:first:(cars));

car_alert(Car,P_car)->
  [_CarNumber1,Road1,{Cx,Cy},Speed,Dir,_Color]=ets:lookup(cars,Car), %get car details
  Alive=ets:member(cars,P_car),
  case Alive of
    true->
      [_CarNumber,Road,{Cx,Cy},Speed,Dir,_Color]=ets:lookup(cars,P_car)
  end


tl_alert(Car,'$end_of_table')-> % start
  tl_alert(Car,ets:first(traffic_light));

tl_alert(Car,Junction)->
  [_CarNumber,Road,{Cx,Cy},Speed,Dir,_Color]=ets:lookup(cars,Car), %get car details
  [{R1,R2},{Jx,Jy},TLPid]=ets:lookup(traffic_light,Junction), %get first junction details
  case Road==R1 orelse Road==R2 of %if the car is on the same road of the junction
    true-> %same road
      case Dir of
        north-> %car is moving north
          case Jy-Cy<25 orelse Jy-Cy>0 of   %check if car is near the junction, and didn't already passed it.
            true->
              cars:tl_alert(Car,sys:get_state(TLPid)),
              timer:sleep(1500),
              tl_alert(Car,ets:first(traffic_light));
            _->
              tl_alert(Car,ets:next(traffic_light,Junction))
          end;
        south-> %car is moving north
          case Cy-Jy<25 orelse Cy-Jy>0 of   %check if car is near the junction, and didn't already passed it.
            true->
              cars:tl_alert(Car,sys:get_state(TLPid)),
              timer:sleep(1500),
              tl_alert(Car,ets:first(traffic_light));
            _->
              tl_alert(Car,ets:next(traffic_light,Junction))
          end;
        west-> %car is moving north
          case Cx-Jx<25 orelse Cx-Jx>0 of   %check if car is near the junction, and didn't already passed it.
            true->
              cars:tl_alert(Car,sys:get_state(TLPid)),
              timer:sleep(1500),
              tl_alert(Car,ets:first(traffic_light));
            _->
              tl_alert(Car,ets:next(traffic_light,Junction))
          end;
        east-> %car is moving north
          case Jx-Cx<25 orelse Jx-Cx>0 of   %check if car is near the junction, and didn't already passed it.
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







