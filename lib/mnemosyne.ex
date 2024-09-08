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

  def listen(map, level) do
    receive do
      {:input, input} ->
        input = String.trim(input)

        case input do
          "exit" ->
            IO.puts("Bye!")

          _ ->
            Parser.command(input)
            listen(map, level)
        end

      {:get, key} ->
        Map.get(map, key, "NIL") |> Parser.show()
        listen(map, level)

      {:set, key, value} ->
        IO.puts("#{has_key(map, key)} #{value}")
        listen(Map.put(map, key, value), level)

      :begin ->
        level = level + 1
        IO.puts(level)

        {level, updated_map} = listen(map, level)

        listen(Map.merge(map, updated_map), level)

      :commit ->
        level = max(level - 1, 0)
        IO.puts(level)
        {level, map}

      :rollback ->
        if level < 1 do
          IO.puts("ERR can not rollback at level #{level}")
          listen(map, level)
        else
          level = level - 1
          IO.puts(level)
          {level, %{}}
        end
    after
      0 ->
        send(self(), {:input, IO.gets("> ")})
        listen(map, level)
    end
  end

  def has_key(map, key) do
    case Map.has_key?(map, key) do
      true -> "TRUE"
      false -> "FALSE"
    end
  end
end
