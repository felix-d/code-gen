defmodule Bulk.Creation.TaskManager do
  use GenServer

  alias Bulk.Creation.StatusManager
  alias Bulk.Creation.Task
  alias Bulk.Shopify.QueueStore

  @timeout 1000 * 15

  defmodule TaskData do
    @enforce_keys [:shop, :id, :timer]
    defstruct [:shop, :id, :timer]
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def start_task(shop, code_count, id, prefix) do
    GenServer.cast(__MODULE__, {:start_task, shop, code_count, id, prefix})
  end

  def start_task(shop, codes, id) do
    GenServer.cast(__MODULE__, {:start_task, shop, codes, id})
  end

  def clear_timeout(task_pid) do
    GenServer.cast(__MODULE__, {:clear_timeout, task_pid})
  end

  # Generate codes
  def handle_cast({:start_task, shop, code_count, id, prefix}, state) do
    {:ok, task_pid} = Task.start_link(shop, id, code_count, prefix)

    StatusManager.task_started(id: id, code_count: code_count)

    timer = Process.send_after(self(), {:kill_task, task_pid}, @timeout)

    {:noreply, state |> Map.put(task_pid, %TaskData{id: id, timer: timer, shop: shop})}
  end

  # Existing codes
  def handle_cast({:start_task, shop, codes, id}, state) do
    {:ok, task_pid} = Task.start_link(shop, id, codes)

    StatusManager.task_started(id: id, code_count: length(codes))

    timer = Process.send_after(self(), {:kill_task, task_pid}, @timeout)

    {:noreply, state |> Map.put(task_pid, %TaskData{id: id, timer: timer, shop: shop})}
  end

  def handle_cast({:clear_timeout, task_pid}, state) do
    %{^task_pid => %TaskData{id: id, timer: timer, shop: shop}} = state

    Process.cancel_timer(timer)
    timer = Process.send_after(self(), {:kill_task, task_pid}, @timeout)

    {:noreply, %{state | task_pid => %TaskData{id: id, timer: timer, shop: shop}}}
  end

  def handle_info({:kill_task, task_pid}, state) do
    Process.exit(task_pid, :kill)

    {:noreply, state}
  end

  def handle_info({:EXIT, task_pid, :killed}, state) do
    %{^task_pid => %TaskData{id: id, timer: timer, shop: shop}} = state

    Process.cancel_timer(timer)
    clear_requests_enqueued_from_task(shop, task_pid)
    StatusManager.task_error(id)

    {:noreply, Map.delete(state, task_pid)}
  end

  def handle_info({:EXIT, task_pid, :normal}, state) do
    %{^task_pid => %TaskData{id: id, timer: timer}} = state

    Process.cancel_timer(timer)
    StatusManager.task_finished(id)

    {:noreply, Map.delete(state, task_pid)}
  end

  def handle_info({:EXIT, task_pid, _}, state) do
    %{^task_pid => %TaskData{id: id, timer: timer, shop: shop}} = state

    Process.cancel_timer(timer)
    clear_requests_enqueued_from_task(shop, task_pid)
    StatusManager.task_error(id)

    {:noreply, Map.delete(state, task_pid)}
  end

  defp clear_requests_enqueued_from_task(shop, task_pid) do
    case QueueStore.get(shop.name) do
      queue when is_pid(queue) ->
        ThrottledQueue.remove(queue, from: task_pid)
      _ -> nil
    end
  end
end
