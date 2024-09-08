defmodule MnemosyneTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "handle set only on first level" do
    task = Task.async(fn -> Mnemosyne.listen(%{}, 0) end)

    send(task.pid, {:set, "test", "Success"})
    send(task.pid, :commit)

    {level, final_map} = Task.await(task)

    assert Map.get(final_map, "test") == "Success"
    assert level == 0
  end

  test "handle set with two levels and rollback" do
    task = Task.async(fn -> Mnemosyne.listen(%{}, 0) end)

    send(task.pid, {:set, "test", "Success"})
    send(task.pid, :begin)
    send(task.pid, {:set, "test2", 5})
    send(task.pid, {:set, "test3", "Shall it remember?"})
    send(task.pid, :rollback)
    send(task.pid, :commit)

    {level, final_map} = Task.await(task)

    assert Map.get(final_map, "test3") == nil
    assert level == 0
  end

  test "handle set with two levels commit" do
    task = Task.async(fn -> Mnemosyne.listen(%{}, 0) end)

    send(task.pid, {:set, "test", "Success"})
    send(task.pid, :begin)
    send(task.pid, {:set, "test2", 5})
    send(task.pid, {:set, "test3", "Shall it remember?"})
    send(task.pid, :commit)
    send(task.pid, :commit)

    {level, final_map} = Task.await(task)

    assert Map.get(final_map, "test3") == "Shall it remember?"
    assert Map.get(final_map, "test2") == 5
    assert level == 0
  end
end
