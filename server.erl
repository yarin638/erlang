%%%-------------------------------------------------------------------
%%% @author yarinabutbul
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Aug 2021 20:07
%%%-------------------------------------------------------------------
-module(server).
-author("yarinabutbul").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,makeAnAtom/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(server_state, {}).

%%%===================================================================
%%% API
%%%===================================================================

%% @doc Spawns the server and registers the local name (unique)
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%% @private
%% @doc Initializes the server
-spec(init(Args :: term()) ->
  {ok, State :: #server_state{}} | {ok, State :: #server_state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
%%%events
%start_car(Name,X,Y,Dir,Road)-> gen_server:cast(?MODULE,{start_car,Name,X,Y,Dir,Road}). % initialize car process
%start_car(Name,X,Y,Dir,Road)-> gen_server:cast(?MODULE,{start_car,Name,X,Y,Dir,Road}). % initialize car process
%%%%%%%%%
init([]) ->
  ets:new(cars,[set,public,named_table]), ets:new(junction,[set,public,named_table]),ets:new(traffic_light,[set,public,named_table]),
  %ets:insert(junction,{{1130,105},[0,1],[2,3],[east,north]}),
  %ets:lookup(junction,{1,7}),
 %cars:start(yan,200,600,east,0),
 % ets:insert(cars,{yarin,0,{290,400},0,east,red}),
  %spawn(alerts,switch_area,[yarin]),
  %traffic_light:start(0,{1137,100},t1),
  cars:start(shahar,645,100,north,22),
  cars:start(yarin,645,70,north,22),
  cars:start(shahar,800,100,north,22),
  traffic_light:start({22,645,65,red},t1),
  %traffic_light:start({1,1055,100,green},t2),

  {ok, #server_state{}}.

%% @private
%% @doc Handling call messages
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #server_state{}) ->
  {reply, Reply :: term(), NewState :: #server_state{}} |
  {reply, Reply :: term(), NewState :: #server_state{}, timeout() | hibernate} |
  {noreply, NewState :: #server_state{}} |
  {noreply, NewState :: #server_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #server_state{}} |
  {stop, Reason :: term(), NewState :: #server_state{}}).
handle_call(firstcar, _From, State) ->
  CarTosend=ets:lookup(cars,ets:first(cars)),
  {reply,CarTosend, State};

handle_call({nextcar,Car}, _From, State) ->
  Bool=ets:member(cars,Car),
  if
    Bool=:=true->CarTosend=ets:lookup(cars,ets:next(cars,Car));
    true->CarTosend=[] end,
  {reply,CarTosend, State}.
%% @private


%% @doc Handling cast messages
-spec(handle_cast(Request :: term(), State :: #server_state{}) ->
  {noreply, NewState :: #server_state{}} |
  {noreply, NewState :: #server_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #server_state{}}).

handle_cast({start_car,Name,X,Y,Dir,Road}, State) ->
  %io:format("car started:~p,~p,~p,~p",[Name,X,Y,Dir]),
  %io:format("starting car"),
  Newname=makeAnAtom(X,Name),
  cars:start(Newname,X,Y,Dir,Road),
  {noreply, State};
handle_cast({start_traffic_light,Road,X,Y,Color,Name}, State) ->
  traffic_light:start({Road,X,Y,Color},Name),
  {noreply, State};
handle_cast({start_junc,Cord,RoadlisIn,Roadlisout,Dirlist}, State) ->
  ets:insert(junction,{Cord,RoadlisIn,Roadlisout,Dirlist}),
  {noreply, State}.


%% @private
%% @doc Handling all non call/cast messages
-spec(handle_info(Info :: timeout() | term(), State :: #server_state{}) ->
  {noreply, NewState :: #server_state{}} |
  {noreply, NewState :: #server_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #server_state{}}).
handle_info(_Info, State = #server_state{}) ->
  {noreply, State}.

%% @private
%% @doc This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #server_state{}) -> term()).
terminate(_Reason, _State = #server_state{}) ->
  ok.

%% @private
%% @doc Convert process state when code is changed
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #server_state{},
    Extra :: term()) ->
  {ok, NewState :: #server_state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State = #server_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
makeAnAtom(X,Name)->list_to_atom(string:join([atom_to_list(Name),integer_to_list(X)],"")).