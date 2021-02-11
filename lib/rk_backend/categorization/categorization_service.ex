defmodule RkBackend.Categorization.CategorizationService do
  use HTTPoison.Base

  @expected_fields ~w(category)
  @classifier_protocol Application.compile_env(:rk_backend, RkBackend.Categorization)[:protocol]
  @classifier_address Application.compile_env(:rk_backend, RkBackend.Categorization)[:address]
  @classifier_port Application.compile_env(:rk_backend, RkBackend.Categorization)[:port]

  def process_request_url(url) do
    "#{@classifier_protocol}://#{@classifier_address}:#{@classifier_port}#{url}"
  end

  def process_response_body(body) do
    body
    |> Jason.decode!()
    |> Map.take(@expected_fields)
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
  end

  def get_category(text) when is_binary(text) do
    case __MODULE__.get("/classify", [], params: [text: text]) do
      {:ok, %HTTPoison.Response{body: [category: category], status_code: 200}} ->
        {:ok, category}

      {:ok, %HTTPoison.Response{}} ->
        {:error, :internal_error}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
