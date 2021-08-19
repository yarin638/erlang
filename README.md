# Erlang Project- Managing car traffic

## Background
In this project we have implement a code that managing traffic, we have implemented roads, junctions, traffic light and cars.
</br>
Our project works on 5 different computers: main computer and 4 servers computers.
</br>
Each one of the servers responsible for different area on the map. 

## Main Node:
</br>
1.Responsible for the graphic part, the graphic has been implemented by wx_object.
</br>
2.Initiate the 4 servers.
</br>
3.Use the ets data bases of each server to update in own ets for graphic and for back up.
</br>
4.If one of the server is falling, the main computer will give one of the other servers control of this area of the map.

## Server:
1.4 servers, each one is a different node.
</br>
2.Implemented by gen_server
</br>
3.Each server has each own ets for cars,junctions and traffic lights data.
</br>
4.each servers initiate its own cars, junction and traffic lights.

## Cars:
1.Implemented by gen_statem
</br>
2.Each car is different process,
</br>
3.Each car has only 2 states: Stop and straight.
</br>
4.Each car has multiple events such as Car alert, turn alert, traffic light alerts and more.

## Alerts:
1.Each car create new process for each on of the events.
</br>
2.Each Alert process responsible to alert it's car that event occured.

## Trafic Light:
1.Implemented by gen_statem
</br>
2.has 3 states: green, red, yellow.
</br>
3.the only event is timeout for the color of the traffic light to switch color.


## Activation Manual:
</br> 
Multiple computer:
Write inside the header the address of the four servers:
</br>
-define(server1, 'server1@IP_ADDRESS1).
</br>
-define(server2, 'server2@IP_ADDRESS2).
</br>
-define(server3,'server3@IP_ADDRESS3').
</br>
-define(server4, 'server3@ IP_ADDRESS4').
</br>
Single computer:
</br>
-define(server1, 'server1@IP_ADDRESS1).
</br>
-define(server2, 'server2@IP_ADDRESS1).
</br>
-define(server3,'server3@IP_ADDRESS1').
</br>
-define(server4, 'server3@ IP_ADDRESS1').
</br>
</br>
in both computers:
</br>
For each server, open a terminal and enter the following command:
</br>
erl -setcookie dough -name serverN@IP_ADDRESS abc
</br>
when N is the number of the server
</br>
In the main node enter this command:
</br>
erl -setcookie dough -name home@IP_ADDRESS abc
</br>
now in each one of the five terminals enter:
</br>
lc([main,server,traffic_light,alerts,cars]).
</br>
now you can initate the program by writing the following command at the main node:
</br>
main:start().

## video of our work:
https://www.youtube.com/watch?v=FkybrVXfNT0
