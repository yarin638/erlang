# erlang
Activation Manual:
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
