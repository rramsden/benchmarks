%% You can set an ETS key inside a pattern using ets:match/2 Erlang docs say
%% its very effecient if you pass in the key inside ets:match, but is it really O_o?
-module(ets_lookup_vs_match).

-export([start/0]).

-record(record, {
        key,
        value
        }).

-define(TIMES, 100000).
-define(TABLE, table).

start() ->
    Ids = lists:seq(1, ?TIMES),
    ets:new(?TABLE, [named_table, {keypos, 2}]),
    [ets:insert(table, #record{key=Key}) || Key <- Ids],

    Fun1 = fun() ->
            lists:foreach(fun(Key) ->
                    ets:lookup(?TABLE, Key)
            end, Ids)
    end,
    Fun2 = fun() ->
            lists:foreach(fun(Key) ->
                    ets:match(?TABLE, #record{key=Key, value='$1'})
            end, Ids)
    end,

    T1 = mean(Fun1, 10) / 1000.0,
    T2 = mean(Fun2, 10) / 1000.0,

    io:format("ets:lookup => ~p ms~n", [T1]),
    io:format("ets:match => ~p ms~n", [T2]).

mean(Fun, N) ->
    lists:sum([begin {T, _} = timer:tc(Fun), T end || _ <- lists:seq(1, N)]) / N.
