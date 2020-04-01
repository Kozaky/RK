defmodule RkBackendWeb.Context do

  def dataloader() do
    Dataloader.new
    |> Dataloader.add_source(RkBackend, RkBackend.rk_data())
  end


end
