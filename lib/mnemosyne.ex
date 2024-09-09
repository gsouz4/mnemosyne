defmodule Mnemosyne do
  @moduledoc """
  Ponto de entrada para a CLI.
  """

  @doc """
  A função main recebe os argumentos passados na linha de
  comando como lista de strings e executa a CLI.
  """

  def main(_args) do
    listen(%{}, 0)
  end

  def listen(map, level, io \\ IO) do
    input = io.gets("> ") |> String.trim()

    case input do
      "exit" ->
        IO.puts("Bye!")

      _ ->
        input
        |> Command.parse()
        |> handle_command(map, level, io)
    end
  end

  def has_key(map, key) do
    if Map.has_key?(map, key), do: "TRUE", else: "FALSE"
  end

  def handle_command({:error, reason}, map, level, io) do
    reason |> Hermes.print()
    listen(map, level, io)
  end

  def handle_command({:get, key}, map, level, io) do
    Map.get(map, key, "NIL") |> Hermes.print()
    listen(map, level, io)
  end

  def handle_command({:set, key, value}, map, level, io) do
    "#{has_key(map, key)} #{value}" |> Hermes.print(:set)
    listen(Map.put(map, key, value), level, io)
  end

  def handle_command(:begin, map, level, io) do
    level =
      level
      |> handle_level(:add)

    level
    |> Hermes.print()

    {updated_map, level} = listen(map, level, io)
    listen(Map.merge(map, updated_map), level, io)
  end

  def handle_command(:commit, map, level, _io) do
    level =
      level
      |> handle_level(:decrease)

    level
    |> Hermes.print()

    {map, level}
  end

  def handle_command(:rollback, map, level, io) do
    if level < 1 do
      "ERR can not rollback at level #{level}"
      |> Hermes.print()

      listen(map, level, io)
    else
      level
      |> handle_level(:decrease)
      |> Hermes.print()

      {%{}, level}
    end
  end

  def handle_level(level, :add) do
    level + 1
  end

  def handle_level(level, :decrease) do
    max(level - 1, 0)
  end
end
