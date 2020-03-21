defmodule ArtStore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      ArtStore.Repo,
      {ConCache,
      [
        name: :current_user_cache,
        ttl_check_interval: 2_000,
        global_ttl: 2_000,
        touch_on_read: true
      ]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ArtStore.Supervisor)
  end
end
