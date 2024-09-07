defmodule Mnemosyne do
  @moduledoc """
  Ponto de entrada para a CLI.
  """

  @doc """
  A função main recebe os argumentos passados na linha de
  comando como lista de strings e executa a CLI.
  """

  def main(_args) do
    handle_input(%{}, 0)
  end

  def handle_input(map, level) do
    receive do
      {:input, input} ->
        input = String.trim(input)

        case input do
          "exit" ->
            IO.puts("Bye!")

          _ ->
            case Parser.validate(input) do
              {:ok, query} -> parse_command(query)
              {:error, reason} -> IO.puts(reason)
            end

            handle_input(map, level)
        end

      {:get, key} ->
        IO.puts(Map.get(map, key, "NIL"))
        handle_input(map, level)

      {:set, key, value} ->
        IO.puts("#{Map.has_key?(map, key) |> to_string() |> String.upcase()} #{value}")
        handle_input(Map.put(map, key, value), level)

      :begin ->
        level = level + 1
        IO.puts(level)

        {level, updated_map} = handle_input(map, level)

        handle_input(Map.merge(map, updated_map), level)

      :commit ->
        level = level - 1
        IO.puts(level)
        {level, map}

      :rollback ->
        if level < 1 do
          IO.puts("ERR can not rollback at level #{level}")
          handle_input(map, level)
        else
          level = level - 1
          IO.puts(level)
          {level, %{}}
        end
    after
      0 ->
        send(self(), {:input, IO.gets("> ")})
        handle_input(map, level)
    end
  end

  def execute([command | args]) do
    command
    |> String.downcase()
    |> String.to_atom()
    |> handle_command(args)
  end

  def parse_command(query) do
    query
    |> String.split(" ")
    |> execute()
  end

  def handle_command(:get, [_ | value]) when value != [],
    do: IO.puts("ERR \"GET <key> - Syntax Error\"")

  def handle_command(:get, [key | _]) do
    send(self(), {:get, key})
  end

  def handle_command(:set, [_ | value]) when value == [],
    do: IO.puts("ERR \"SET <key> <value> - Syntax Error\"")

  def handle_command(:set, [key | value]) do
    send(self(), {:set, key, value})
  end

  def handle_command(:begin, []) do
    send(self(), :begin)
  end

  def handle_command(:commit, []) do
    send(self(), :commit)
  end

  def handle_command(:rollback, []) do
    send(self(), :rollback)
  end
end
