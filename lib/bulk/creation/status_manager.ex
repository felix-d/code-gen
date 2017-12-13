defmodule Bulk.Creation.StatusManager do
  use GenServer

  defmodule Status do
    defstruct id: nil, code_count: nil, step: 0, max_step: nil

    def progress(%Status{step: step, max_step: max_step}) do
      case step do
        0 -> 0
        step -> step / max_step
      end
    end

    def initialized?(%Status{max_step: max_step}) do
      max_step != nil
    end

    def dump(%Status{id: id, code_count: code_count} = status) do
      %{
        id: id,
        code_count: code_count,
        progress: Status.progress(status),
      }
    end

    def increment(%Status{step: step} = status) do
      %Status{status | step: step + 1}
    end

    def init(%Status{} = status, max_step) do
      %Status{status | max_step: max_step}
    end
  end

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def task_started(id: id, code_count: code_count) do
    GenServer.call(__MODULE__, {:task_started, id: id, code_count: code_count})
  end

  def init_progress(id, max_step) do
    GenServer.call(__MODULE__, {:init_progress, id, max_step})
  end

  def update_progress(id) do
    GenServer.call(__MODULE__, {:update_progress, id})
  end

  def initialized?(id) do
    GenServer.call(__MODULE__, {:initialized?, id})
  end

  def task_finished(id) do
    GenServer.call(__MODULE__, {:task_finished, id})
  end

  def task_error(id) do
    GenServer.call(__MODULE__, {:task_error, id})
  end

  def task_status(id) do
    GenServer.call(__MODULE__, {:task_status, id})
  end

  def handle_call({:task_started, id: id, code_count: code_count}, _from, state) do
    status = %Status{id: id, code_count: code_count}

    {:reply, :ok, Map.put(state, id, status)}
  end

  def handle_call({:task_finished, id}, _from, state) do
    {:reply, :ok, Map.delete(state, id)}
  end

  def handle_call({:task_error, id}, _from, state) do
    %{^id => status} = state

    broadcast(id, "error", status)

    {:reply, :ok, Map.delete(state, id)}
  end

  def handle_call({:initialized?, id}, _from, state) do
    %{^id => status} = state

    {:reply, Status.initialized?(status), state}
  end

  def handle_call({:task_status, id}, _from, state) do
    if Map.has_key?(state, id) do
      {:reply, Map.get(state, id) |> Status.dump, state}
    else
      {:reply, nil, state}
    end
  end

  def handle_call({:init_progress, id, max_step}, _from, state) do
    %{^id => status} = state

    status = Status.init(status, max_step)
    broadcast(id, "progress", status)

    {:reply, :ok, %{state | id => status}}
  end

  def handle_call({:update_progress, id}, _from, state) do
    %{^id => status} = state

    status = Status.increment(status)
    broadcast(id, "progress", status)

    {:reply, :ok, %{state | id => status}}
  end

  defp broadcast(id, topic, status) do
    BulkWeb.Endpoint.broadcast("bulk:" <> id, topic, Status.dump(status))
  end
end
