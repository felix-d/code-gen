defmodule Bulk.Creation.Task do
  use Task

  alias Bulk.Shopify.Client
  alias Bulk.Shopify.Creation
  alias Bulk.Creation.StatusManager
  alias Bulk.Creation.TaskManager

  require IEx
  require Logger
  @max_discount_codes 100

  # Generate codes
  def start_link(shop, id, code_count, prefix) do
    Task.start_link(__MODULE__, :run, [shop, id, code_count, prefix])
  end

  # Existing codes
  def start_link(shop, id, codes) do
    Task.start_link(__MODULE__, :run, [shop, id, codes])
  end

  # Generate codes
  def run(shop, id, count, prefix) do
    {:ok, client} = Client.start_link(shop.name, token: shop.shopify_token, throttled: true)

    # chunks returns a list of chunk [100, 100, 100, 45]
    refs = chunks(count) |> Enum.map(fn chunk ->
      generate_codes(chunk, prefix) |> create_codes(client, id)
    end)

    ref_count = length(refs)

    notify_position(id, hd(refs), ref_count)
    notify_progress(client, id, ref_count)
  end

  # Existing codes
  def run(shop, id, codes) do
    {:ok, client} = Client.start_link(shop.name, token: shop.shopify_token, throttled: true)

    Logger.debug("chunks: #{length(codes) |> chunks |> inspect}")
    refs = chunks(length(codes)) |> Enum.with_index |> Enum.map(fn {chunk, i} ->
      floor = @max_discount_codes * i
      Logger.debug("floor: #{floor}")

      floor..(floor + chunk - 1)
      |> Enum.map(&(%{code: Enum.at(codes, &1)}))
      |> create_codes(client, id)
    end)

    ref_count = length(refs)

    notify_position(id, hd(refs), ref_count)
    notify_progress(client, id, ref_count)
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
        "#{prefix}-#{SecureRandom.hex(4) |> String.upcase}"
      else
        SecureRandom.hex(6) |> String.upcase
      end
    end)
    |> Enum.map(&(%{code: &1}))
  end

  defp notify_position(id, head_ref, chunk_count) do
    receive do
      {:position, ^head_ref, i} ->
        TaskManager.clear_timeout(self())

        case StatusManager.initialized?(id) do
          false -> StatusManager.init_progress(id, i + chunk_count * 2)
          true -> StatusManager.update_progress(id)
        end

        notify_position(id, head_ref, chunk_count)
      {:dequeued, ^head_ref} ->
        TaskManager.clear_timeout(self())

        unless StatusManager.initialized?(id) do
          StatusManager.init_progress(id, chunk_count * 2)
        end
    end
  end

  defp notify_progress(client, id, ref_count) do
    extract_creation_ids(client, id, ref_count)
    |> Enum.each(&Task.await(&1, 600_000))
  end

  defp extract_creation_ids(client, id, ref_count, results \\ []) do
    if length(results) == ref_count do
      results
    else
      receive do
        {:result, _ref, creation} ->
          TaskManager.clear_timeout(self())
          StatusManager.update_progress(id)

          task_pid = self()
          task = Task.async(fn -> Creation.id(creation) |> wait_for_creation(task_pid, client, id) end)

          extract_creation_ids(client, id, ref_count, [task | results])
      end
    end
  end

  defp wait_for_creation(creation_id, task_pid, client, id) do
    {:ok, ref, _} = Creation.get(client, id, creation_id)

    receive do
      {:result, ^ref, creation} ->
        case Creation.status(creation) do
          "completed" ->
            TaskManager.clear_timeout(task_pid)
            StatusManager.update_progress(id)
          _ -> wait_for_creation(creation_id, task_pid, client, id)
        end
    end
  end

  defp create_codes(codes, client, id) do
    params = %{discount_codes: codes}
    {:ok, ref, _} = Creation.create(client, id, params)
    ref
  end
end
