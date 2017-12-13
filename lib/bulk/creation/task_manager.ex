defmodule Bulk.Creation.TaskManager do
  use GenServer

  alias Bulk.Creation.StatusManager
  alias Bulk.Creation.Task

  @timeout 1000 * 60

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

  def clear_timeout(task_pid) do
    GenServer.cast(__MODULE__, {:clear_timeout, task_pid})
  end

  def handle_cast({:start_task, shop, code_count, id, prefix}, state) do
    {:ok, task_pid} = Task.start_link(shop, id, code_count, prefix)

    StatusManager.task_started(id: id, code_count: code_count)

    timer = Process.send_after(self(), {:kill_task, task_pid}, @timeout)

    {:noreply, state |> Map.put(task_pid, {id, timer})}
  end

  def handle_cast({:clear_timeout, task_pid}, state) do
    %{^task_pid => {id, timer}} = state

    Process.cancel_timer(timer)
    timer = Process.send_after(self(), {:kill_task, task_pid}, @timeout)

    {:noreply, %{state | task_pid => {id, timer}}}
  end

  def handle_info({:EXIT, task_pid, :killed}, state) do
    %{^task_pid => {id, timer}} = state

    Process.cancel_timer(timer)
    StatusManager.task_error(id)

    {:noreply, Map.delete(state, task_pid)}
  end

  def handle_info({:EXIT, task_pid, :normal}, state) do
    %{^task_pid => {id, timer}} = state

    Process.cancel_timer(timer)
    StatusManager.task_finished(id)

    {:noreply, Map.delete(state, task_pid)}
  end
end
