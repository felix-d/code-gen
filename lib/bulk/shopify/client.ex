defmodule Bulk.Shopify.Client do
  use Agent
  alias Bulk.Shopify.QueueStore
  require Logger

  def start_link(shop_name, opts \\ []) do
    token = Keyword.get(opts, :token, nil)
    throttled = Keyword.get(opts, :throttled, false)

    url = "https://#{shop_name}"

    queue = if throttled, do: start_queue(shop_name)

    Agent.start_link(fn -> {url, token, queue} end)
  end

  def get(pid, path) do
    from = self()
    Agent.get(pid, fn {url, token, queue} ->
      process(from, queue, fn ->
        response = HTTPoison.get!("#{url}#{path}", headers(token))
        log_response(response)
        Poison.decode!(response.body)
      end)
    end)
  end

  def post(pid, path, params) do
    from = self()
    Agent.get(pid, fn {url, token, queue} ->
      process(from, queue, fn ->
        log_params(params)
        response = HTTPoison.post!("#{url}#{path}", Poison.encode!(params), headers(token))
        log_response(response)
        Poison.decode!(response.body)
      end)
    end)
  end

  def process(from, queue, call) do
    case queue do
      nil -> call.()
      queue ->
        client = self()
        pid = spawn_link(fn ->
          send(client, {self(), ThrottledQueue.enqueue(queue, call)})
          receive_messages(from)
        end)
        receive do
          {^pid, resp} -> resp
        end
    end
  end

  def receive_messages(from) do
    receive do
      {:result, _, _} = msg ->
        send(from, msg)
      {:error, _, _} = msg ->
        send(from, msg)
      msg ->
        send(from, msg)
        receive_messages(from)
    end
  end

  defp log_response(response) do
    resp = case response do
      {:ok, resp} -> resp
      resp -> resp
    end

    "#{inspect(Poison.decode!(resp.body))}" |> Logger.debug
  end

  def log_params(params) do
    "#{inspect(params)}" |> Logger.debug
  end

  defp headers(token) do
    base_headers = [{"Content-Type", "application/json"}]
    if token do
      [{"X-Shopify-Access-Token", token} | base_headers]
    else
      base_headers
    end
  end

  defp start_queue(name) do
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
