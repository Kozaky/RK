defmodule RkBackend.Logic.Auth.SessionService do
  use GenServer

  alias RkBackend.Repo.Auth.User
  alias RkBackend.Repo.Auth.Role

  defstruct user_id: nil, token: nil, role: nil

  @type t :: %__MODULE__{
          user_id: integer(),
          token: String.t(),
          role: %Role{}
        }

  @registry SessionService.Registry
  @supervisor SessionService.Supervisor

  require Logger

  # -------------#
  # Client - API #
  # -------------#

  @moduledoc """
  Documentation for SessionStore.
  Store user tokens and roles
  """

  @doc """
  Initiate a SessionService
  """
  @spec start(User.__struct__(), integer()) :: DynamicSupervisor.on_start_child()
  def start(%User{id: user_id, role: role}, token) do
    opts = [
      user_id: user_id,
      token: token,
      role: role,
      name: {:via, Registry, {@registry, "user" <> Integer.to_string(user_id)}}
    ]

    DynamicSupervisor.start_child(@supervisor, {__MODULE__, opts})
  end

  @spec start_link(keyword) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    {name, opts} = Keyword.pop(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Determines if the user has any of the the given roles
  """
  @spec has_any_role?(GenServer.server(), [String.t()]) :: boolean()
  def has_any_role?(pid, roles), do: GenServer.call(pid, {:has_any_role, roles})

  @doc """
  Updates the roles of this user
  """
  @spec update_role!(GenServer.server(), %Role{}) :: {:ok, :role_updated}
  def update_role!(pid, role), do: GenServer.call(pid, {:update_role, role})

  @doc """
  Gets the current state
  """
  @spec get_state(GenServer.server()) :: %__MODULE__{}
  def get_state(pid), do: GenServer.call(pid, {:get_state})

  @doc """
  Look up the given process_name in the Registry
  """
  @spec lookup(String.t()) :: {:ok, pid()} | {:error, :not_found}
  def lookup(process_name) do
    case Registry.lookup(@registry, process_name) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  ## ---------- ##
  # Server - API #
  ## -----------##

  @impl true
  @spec init(keyword) :: {:ok, RkBackend.Logic.Auth.SessionService.t()}
  def init(opts) do
    state = %__MODULE__{
      user_id: Keyword.fetch!(opts, :user_id),
      token: Keyword.fetch!(opts, :token),
      role: Keyword.fetch!(opts, :role)
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:has_any_role, roles}, _from, state) do
    {:reply, state.role.type in roles, state}
  end

  @impl true
  def handle_call({:update_role, role}, _from, state) do
    state = %{state | role: role}
    {:reply, {:ok, :role_updated}, state}
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end
end
