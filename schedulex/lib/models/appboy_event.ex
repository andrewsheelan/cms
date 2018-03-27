defmodule Schedulex.Models.AppboyEvent do
  use Ecto.Schema
  alias Schedulex.Repo
  alias Schedulex.Models.AppboyEvent
  import Ecto.Query, only: [from: 2]
  schema "appboy_events" do
    field :user_id, :integer
    field :event_name, :string
    field :status, :string
    field :date_sent, :utc_datetime
  end

  @doc """
  Select clause
  Examples

      iex> Schedulex.Models.AppboyEvent.users_in(table_name, ids)
      %Schedulex.Models.AppboyEvent{}
  """
  def users_in(tbl, ids) do
    from(
      p in {tbl, AppboyEvent},
      where: p.id in ^ids
    ) |> Repo.all
  end

  @doc """
  Update status
  Examples

      iex> Schedulex.Models.AppboyEvent.users_in(table_name, ids)
      %Schedulex.Models.AppboyEvent{}
  """
  def set_status_for_users_in(tbl, ids, status) do
    from(
      p in {tbl, AppboyEvent},
      where: p.id in ^ids,
      update: [set: [status: ^status, date_sent: ^NaiveDateTime.utc_now]]
    ) |> Schedulex.Repo.update_all([])
  end

  @doc """
  Fetch in batches
  Examples

      iex> Schedulex.Models.AppboyEvent.users_in(table_name, ids)
      %Schedulex.Models.AppboyEvent{}
  """
  @batch_size 50
  def batch_unprocessed_users(tbl) do
    from(
      u in {tbl, AppboyEvent},
      select: u.id,
      where: is_nil(u.status) and not is_nil(u.user_id) and not is_nil(u.event_name),
      limit: @batch_size
    ) |> Repo.all
  end
end
