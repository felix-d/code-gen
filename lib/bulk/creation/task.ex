defmodule Bulk.Creation.Task do
  use Task

  require Logger

  alias Bulk.Creation.QueueStore
  alias Bulk.Creation.NotifierStore
  alias Bulk.Creation.Notifier
  alias Bulk.Shopify.Client
  alias Bulk.Shopify.Creation

  @max_discount_codes 100

  def start(shop, count, id, prefix) do
    Task.start(__MODULE__, :run, [shop, id, count, prefix])
  end

  def run(shop, id, count, prefix) do
    {:ok, client} = Client.start_link(shop.name, shop.token)
    queue = get_or_create_queue(shop.name)

    refs = chunks(count)
    |> Enum.map(fn chunk ->
      codes = generate_codes(chunk, prefix)
      create_codes(client, id, queue, codes)
    end)

    ref_count = length(refs)

    notifier = notify_about_position_in_queue(id, count, hd(refs), ref_count)
    notify_about_creation_progress(client, id, queue, ref_count, notifier)

    NotifierStore.del(id)
  end

  defp chunks(count) do
    num_tasks = div(count, @max_discount_codes)
    remainder = rem(count, @max_discount_codes)

    chunks = Enum.to_list(0..num_tasks) |> Enum.reject(&(&1 <= 0)) |> Enum.map(fn _ -> @max_discount_codes end)

    if remainder > 0 do
      [remainder | chunks]
    else
      chunks
    end
  end

  defp generate_codes(count, prefix) do
    0..count - 1
    |> Enum.map(fn _ ->
      if prefix != nil do
        "#{prefix}-#{SecureRandom.hex(8)}"
      else
        SecureRandom.hex(16)
      end
    end)
    |> Enum.map(&(%{code: &1}))
  end

  # TODO: refactor this method to extract the notifier initialization
  defp notify_about_position_in_queue(id, code_count, head_ref, chunk_count, notifier \\ nil) do
    receive do
      {:position, ^head_ref, i} ->
        if notifier == nil do
          notifier = init_notifier(code_count, id, i + chunk_count * 2)
          notify_about_position_in_queue(id, code_count, head_ref, chunk_count, notifier)
        else
          Notifier.increment(notifier)
          notify_about_position_in_queue(id, code_count, head_ref, chunk_count, notifier)
        end
      {:dequeued, ^head_ref} -> notifier || init_notifier(code_count, id, chunk_count * 2)
    end
  end

  defp init_notifier(code_count, id, max_step) do
    {:ok, notifier} = Notifier.start_link(id, %Notifier.State{id: id, code_count: code_count, max_step: max_step})
    NotifierStore.set(id, notifier)
    notifier
  end

  defp notify_about_creation_progress(client, id, queue, ref_count, notifier) do
    extract_creation_ids(client, id, queue, ref_count, notifier)
    |> Enum.each(&Task.await(&1, 600_000))
  end

  defp extract_creation_ids(client, id, queue, ref_count, notifier, results \\ []) do
    if length(results) == ref_count do
      results
    else
      receive do
        {:result, _ref, creation_id} ->
          Notifier.increment(notifier)
          task = Task.async(fn -> wait_for_creation(client, id, queue, creation_id, notifier) end)
          extract_creation_ids(client, id, queue, ref_count, notifier, [task | results])
      end
    end
  end

  defp wait_for_creation(client, id, queue, creation_id, notifier) do
    {:ok, ref, _} = ThrottledQueue.enqueue(queue, fn ->
      Creation.status(client, id, creation_id)
    end)

    receive do
      {:result, ^ref, status} ->
        if status == "completed" do
          Notifier.increment(notifier)
        else
          wait_for_creation(client, id, queue, creation_id, notifier)
        end
    end
  end

  defp create_codes(client, id, queue, codes) do
    params = %{discount_codes: codes}
    {:ok, ref, _} = ThrottledQueue.enqueue(queue, fn ->
      Creation.id(client, id, params)
    end)
    ref
  end

  defp get_or_create_queue(name) do
    case QueueStore.get(name) do
      nil ->
        {:ok, queue} = ThrottledQueue.start(name: String.to_atom(name))
        QueueStore.set(name, queue)
        queue
      queue ->
        QueueStore.touch(name)
        queue
    end
  end
end
