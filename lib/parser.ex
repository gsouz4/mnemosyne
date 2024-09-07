defmodule Parser do
  @valid_commands ["GET", "SET", "BEGIN", "ROLLBACK", "COMMIT"]

  def validate(query) do
    command =
      String.split(query, " ")
      |> Enum.at(0)

    case is_command_valid(command) do
      true -> {:ok, query}
      false -> {:error, "ERR \"No command #{command}\""}
    end
  end

  defp is_command_valid(command) do
    @valid_commands
    |> Enum.member?(command)
  end
end
