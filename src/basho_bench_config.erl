%% -------------------------------------------------------------------
%%
%% basho_bench: Benchmarking Suite
%%
%% Copyright (c) 2009-2010 Basho Techonologies
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------
-module(basho_bench_config).

-export([load/1,
         set/2,
         get/1, get/2]).

-include("basho_bench.hrl").

%% ===================================================================
%% Public API
%% ===================================================================

load(Files) ->
    TermsList =
        [ case file:consult(File) of
              {ok, Terms} ->
                  Terms;
              {error, Reason} ->
                  ?FAIL_MSG("Failed to parse config file ~s: ~p\n", [File, Reason])
          end || File <- Files ],
    load_config(lists:append(TermsList)).

set(Key, Value) ->
    ok = application:set_env(basho_bench, Key, Value).

get(Key) ->
    case application:get_env(basho_bench, Key) of
        {ok, Value} ->
            Value;
        undefined ->
            erlang:error("Missing configuration key", [Key])
    end.

get(Key, Default) ->
    case application:get_env(basho_bench, Key) of
        {ok, Value} ->
            Value;
        _ ->
            Default
    end.


%% ===================================================================
%% Internal functions
%% ===================================================================

load_config([]) ->
    ok;
load_config([{Key, Value} | Rest]) ->
    ?MODULE:set(Key, Value),
    load_config(Rest);
load_config([ Other | Rest]) ->
    ?WARN("Ignoring non-tuple config value: ~p\n", [Other]),
    load_config(Rest).
