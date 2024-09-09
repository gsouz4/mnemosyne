defmodule Hermes do
  def print("NIL"), do: IO.puts("NIL")
  def print(value) when is_integer(value), do: IO.puts(value)

  def print(value) do
    case String.split(value, " ") do
      [_arg] -> IO.puts(value)
      _ -> IO.inspect(value)
    end
  end

  def print(value, :set) do
    IO.puts(value)
  end
end
