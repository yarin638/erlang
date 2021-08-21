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
-include("header.hrl").
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
  %%%%%%%%%%%%%%%%%%%statr and init all the ets tables for the servers%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
  ets:new(cars,[set,public,named_table]), ets:new(junction,[set,public,named_table]),ets:new(traffic_light,[set,public,named_table]),
  ets:new(cars_stats,[set,public,named_table]),
  ets:new(servers,[set,public,named_table]),
  ets:insert(servers,{?Server1,on}),
  ets:insert(servers,{?Server2,on}),
  ets:insert(servers,{?Server3,on}),
  ets:insert(servers,{?Server4,on}),
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


handle_call(firstTl, _From, State) ->
  [{R1,{Jx,Jy},TLPid}]=ets:lookup(traffic_light,ets:first(traffic_light)),
  {Color,0}=sys:get_state(TLPid),
  TlTosend=[{R1,{Jx,Jy},Color}],
  {reply,TlTosend,State};

handle_call({nextTl,Tl}, _From, State) ->%send back the next tl
  Bool=ets:member(traffic_light,Tl),
  if
    Bool=:=true->
      NextTl=ets:lookup(traffic_light,ets:next(traffic_light,Tl)),
      if
        NextTl==[]->
          TlTosend={reply,[],State};
        true->
          [{R1,{Jx,Jy},TLPid}]=NextTl,
            {Color,0}=sys:get_state(TLPid),
            TlTosend=[{R1,{Jx,Jy},Color}]
      end;
    true->TlTosend=[] end,
  {reply,TlTosend, State};

handle_call(firstcar, _From, State) ->%sent the first car in the ets table
  CarTosend=ets:lookup(cars,ets:first(cars)),
  {reply,CarTosend, State};

handle_call(stats, _From, State)->%send the statse
  {reply,ets:tab2list(cars_stats),State};

handle_call({nextcar,Car}, _From, State) ->%send back the next car from the server
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

handle_cast({start_car,Name,X,Y,Dir,Road}, State) ->%start the car on the server
  Newname=makeAnAtom(X,Name),
  cars:start(Newname,X,Y,Dir,Road),
  {noreply, State};

handle_cast({server_down,Server}, State) ->%uptade the severr that another server fall down
  ets:update_element(servers,Server,[{2,off}]),
  {noreply, State};

handle_cast({start_traffic_light,Road,X,Y,Color,Name}, State) ->% start traffic light on the server
  traffic_light:start({Road,X,Y,Color},Name),
  {noreply, State};
handle_cast({start_junc,Cord,RoadlisIn,Roadlisout,Dirlist}, State) ->% start junc on the server
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
