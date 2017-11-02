defmodule Bulk.Creation.Notifier do
  use Agent

  defmodule State do
    defstruct id: nil, code_count: nil, step: 0, max_step: nil
  end

  def start_link(id, %State{} = state) do
    Agent.start_link(fn -> {id, state} end)
  end

  def increment(pid) do
    Agent.update(pid, fn {id, %State{step: step} = state} ->
      new_state = %State{state | step: step + 1}
      BulkWeb.Endpoint.broadcast("bulk:" <> id, "progress", dump(new_state))
      {id, new_state}
    end)
  end

  def progress(pid, socket) do
    Agent.get(pid, fn {_id, state} ->
      Phoenix.Channel.push(socket, "progress", dump(state))
    end)
  end

  defp dump(%State{id: id, code_count: code_count, step: step, max_step: max_step}) do
    %{
      id: id,
      code_count: code_count,
      progress: step / max_step,
    }
  end
end
