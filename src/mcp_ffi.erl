-module(mcp_ffi).

-export([read_line/0, input_schema_to_json/1]).

-spec read_line() -> {ok, unicode:unicode_binary()} | {error, eof | no_data}.
read_line() ->
    case io:get_line("") of
        eof ->
            {error, eof};
        {error, _} ->
            {error, no_data};
        Data when is_binary(Data) ->
            {ok, string:trim(Data, trailing, "\r\n")};
        Data when is_list(Data) ->
            {ok,
             string:trim(
                 unicode:characters_to_binary(Data), trailing, "\r\n")}
    end.

input_schema_to_json(Schema) ->
    json:encode(Schema).
