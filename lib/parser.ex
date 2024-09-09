defmodule Command do
  def parse(command) do
    case String.split(command, " ", parts: 3) do
      ["SET", key, value] ->
        case cast(value) do
          {:error, reason} -> IO.puts(reason)
          value -> {:set, key, cast(value)}
        end

      ["SET", _arg] ->
        {:error, "ERR SET <key> <value> - Syntax Error"}

      ["GET", key] ->
        {:get, key}

      ["GET", _key, _value] ->
        {:error, "ERR GET <key> - Syntax Error"}

      ["BEGIN"] ->
        :begin

      ["ROLLBACK"] ->
        :rollback

      ["COMMIT"] ->
        :commit

      [command, _key, _value] ->
        {:error, "ERR No command #{command}"}

      [command, _key] ->
        {:error, "ERR No command #{command}"}

      _ ->
        {:error, "ERR Invalid command"}
    end
  end

  def cast("NIL"), do: {:error, "ERR Invalid value for command SET: NIL"}

  def cast(value) do
    case Integer.parse(to_string(value)) do
      {number, ""} -> number
      _ -> value
    end
  end
end
