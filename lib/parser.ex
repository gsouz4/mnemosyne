defmodule Parser do
  def command(command) do
    case String.split(command, " ", parts: 3) do
      ["SET", key, value] ->
        case cast(value) do
          {:error, reason} -> IO.puts(reason)
          value -> send(self(), {:set, key, cast(value)})
        end

      ["SET", _arg] ->
        IO.puts("ERR \"SET <key> <value> - Syntax Error\"")

      ["GET", key] ->
        send(self(), {:get, key})

      ["GET", _key, _value] ->
        IO.puts("ERR \"GET <key> - Syntax Error\"")

      ["BEGIN"] ->
        send(self(), :begin)

      ["ROLLBACK"] ->
        send(self(), :rollback)

      ["COMMIT"] ->
        send(self(), :commit)

      [command, _key, _value] ->
        IO.puts("ERR \"No command #{command}\"")

      [command, _key] ->
        IO.puts("ERR \"No command #{command}\"")

      _ ->
        IO.puts("ERR \"Invalid command\"")
    end
  end

  def cast("NIL"), do: {:error, "ERR \"Invalid value for command SET: NIL\""}

  def cast(value) do
    case Integer.parse(value) do
      {number, ""} -> number
      _ -> value
    end
  end

  def show("NIL"), do: IO.puts("NIL")
  def show(value) when is_integer(value), do: IO.puts(value)

  def show(value) do
    case String.split(value, " ") do
      [_arg] -> IO.puts(value)
      _ -> IO.inspect(value)
    end
  end
end
