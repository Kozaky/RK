defmodule RkBackend.Logic.Auth.SessionService do
  use GenServer

  alias RkBackend.Repo.Auth.User
  alias RkBackend.Logic.Auth.SignIn

  defstruct user: nil, token: nil

  @type t :: %__MODULE__{
          user: User.t(),
          token: String.t()
        }

  @registry SessionService.Registry
  @supervisor SessionService.Supervisor
  @max_token_refresh_time 300

  require Logger

  # -------------#
  # Client - API #
  # -------------#

  @moduledoc """
  Documentation for SessionStore.
  Stores users' token and role
  """

  @doc """
  Initiate a SessionService
  """
  @spec start(User.__struct__(), String.t()) :: DynamicSupervisor.on_start_child()
  def start(%User{} = user, token) do
    opts = [
      user: user,
      token: token,
      name: {:via, Registry, {@registry, {__MODULE__, user.id}}}
    ]

    Process.send_after(
      self(),
      :terminate_session_when_token_not_refreshed,
      SignIn.get_max_age() + @max_token_refresh_time
    )

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
  @spec update_role(GenServer.server(), %{field: any()}) :: :ok
  def update_role(pid, attrs), do: GenServer.cast(pid, {:update_role, attrs})

  @doc """
  Gets the current state
  """
  @spec get_state(GenServer.server()) :: __MODULE__.t()
  def get_state(pid), do: GenServer.call(pid, {:get_state})

  @doc """
  Look up the given process_name in the Registry
  """
  @spec lookup({atom(), integer()}) :: {:ok, pid()} | {:error, :not_found}
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
  @spec init(keyword) :: {:ok, __MODULE__.t()}
  def init(opts) do
    state = %__MODULE__{
      user: Keyword.fetch!(opts, :user),
      token: Keyword.fetch!(opts, :token)
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:has_any_role, roles}, _from, state) do
    {:reply, state.user.role.type in roles, state}
  end

  @impl true
  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:update_role, attrs}, state) do
    {:noreply, put_in(state.user.role.type, attrs.type)}
  end

  @impl true
  def handle_cast({:terminate_session_when_token_not_refreshed, _attrs}, state) do
    case SignIn.is_valid_token(state.token) do
      {:ok, _} ->
        Process.send_after(
          self(),
          :terminate_session_when_token_not_refreshed,
          SignIn.get_max_age() + @max_token_refresh_time
        )

      {:error, _} ->
        {:ok, pid} = lookup({__MODULE__, state.user.id})
        DynamicSupervisor.terminate_child(@supervisor, pid)
    end

    {:stop, :session_expired, state}
  end
end
