defmodule FakeIO do
  use Agent

  def start_link(cases_fn) do
    Agent.start_link(fn -> %{calls: 1, cases_fn: cases_fn} end, name: __MODULE__)
  end

  def gets("> ") do
    {calls, cases_fn} =
      Agent.get_and_update(__MODULE__, fn state ->
        {{state.calls, state.cases_fn}, %{calls: state.calls + 1, cases_fn: state.cases_fn}}
      end)

    cases_fn.(calls)
  end
end

defmodule MnemosyneTest do
  use ExUnit.Case

  test "set at level 1 and rollback" do
    FakeIO.start_link(fn times_called ->
      case times_called do
        1 -> "GET test"
        2 -> "SET test arruda"
        3 -> "SET foo bar"
        4 -> "BEGIN"
        5 -> "SET bar baz"
        6 -> "ROLLBACK"
        7 -> "COMMIT"
      end
    end)

    {final_map, level} = Mnemosyne.listen(%{}, 0, FakeIO)

    assert Map.get(final_map, "foo") == "bar"
    assert Map.get(final_map, "bar", "NIL") == "NIL"
    assert level == 0
  end

  test "go up level 2, rollback, commit level 1 and level 0" do
    FakeIO.start_link(fn times_called ->
      case times_called do
        1 -> "GET test"
        2 -> "SET test 3"
        3 -> "SET foo bar"
        4 -> "BEGIN"
        5 -> "SET bar TRUE"
        6 -> "BEGIN"
        7 -> "SET cumbuca beatiful"
        8 -> "ROLLBACK"
        9 -> "COMMIT"
        10 -> "COMMIT"
      end
    end)

    {final_map, level} = Mnemosyne.listen(%{}, 0, FakeIO)

    assert Map.get(final_map, "foo") == "bar"
    assert Map.get(final_map, "bar") == "TRUE"
    assert Map.get(final_map, "cumbuca", "NIL") == "NIL"
    assert level == 0
  end
end
