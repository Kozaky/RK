defmodule RkBackendWeb.Context do
  @moduledoc """
    Context for RkBackendWeb
  """

  def dataloader() do
    Dataloader.new()
    |> Dataloader.add_source(RkBackend, RkBackend.rk_data())
  end
end
