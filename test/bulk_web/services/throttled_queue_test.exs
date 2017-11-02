defmodule BulkWeb.ThrottledQueueTest do
  use ExUnit.Case
  setup do
    BulkWeb.ThrottledQueue.Optimistic.start_link
    :ok
  end


  test 'can enqueue' do
    {:ok, :enqueued, 0} = BulkWeb.ThrottledQueue.Optimistic.enqueue(fn -> :timer.sleep(3000) end)
    {:ok, :enqueued, 0} = BulkWeb.ThrottledQueue.Optimistic.enqueue(fn ->
      IO.puts("kill")
      Process.exit(self(), :kill)
    end)
    {:ok, :enqueued, 1} = BulkWeb.ThrottledQueue.Optimistic.enqueue(fn -> IO.puts "2" end)
    {:ok, :enqueued, 2} = BulkWeb.ThrottledQueue.Optimistic.enqueue(fn -> IO.puts "3" end)
    :timer.sleep 50000
  end
end

def is_even(number, api_key) do
  concurrent = 10
  0..10
  |> Enum.map &Task.async(&(10))

  HTTPPoison.get!("http://api.wolframalpha.com/v1/simple?appid=#{api_key}&i=is+#{number}+even")
  |> Enum.map &Task.async &(&1 % 2 == 0)
  |> Enum.reduce
end

defmodule IsEvenWorker do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def is_even(n) do
    GenServer.call({:is_even, n})
  end

  def handle_call({:is_even, n}, _from, state) do
    res = Map.get(state, n)
    case res do
      _ -> {:reply, res, state}
      nil ->
        res = RustFFIEven.is_even(n)
        {:reply, res, %{state | n => res }}
    end
  end
end

IsEvenWorker.start_link
IsEvenWorker.is_even(2)



