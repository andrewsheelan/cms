defmodule Schedulex.Models.AppboyAttribute do
  use Ecto.Schema
  alias Schedulex.Repo
  alias Schedulex.Models.AppboyAttribute
  alias Schedulex.EctoBatchStream
  import Ecto.Query, only: [from: 2]
  schema "appboy_attributes" do
    field :user_id, :integer
    field :attribute_name, :string
    field :data_value, :string
    field :status, :string
    field :date_sent, :utc_datetime
  end

  @doc """
  Find by condition -- For the love of Active Record
  Examples

      iex> Schedulex.Models.AppboyAttribute.find_by("appboy_user_events", email: "email@example.com")
      %Schedulex.Models.AppboyAttribute{}
  """
  def find_by(tbl, conditions) do
    Repo.get_by {tbl, AppboyAttribute}, conditions
  end

  @doc """
  Select clause
  Examples

      iex> Schedulex.Models.AppboyAttribute.users_in(table_name, user_ids)
      %Schedulex.Models.AppboyAttribute{}
  """
  def users_in(tbl, user_ids) do
    from(
      p in {tbl, AppboyAttribute},
      where: p.user_id in ^user_ids
    ) |> Repo.all
  end

  @doc """
  Update status
  Examples

      iex> Schedulex.Models.AppboyAttribute.users_in(table_name, user_ids)
      %Schedulex.Models.AppboyAttribute{}
  """
  def set_status_for_users_in(tbl, user_ids, status) do
    from(
      p in {tbl, AppboyAttribute},
      where: p.user_id in ^user_ids,
      update: [set: [status: ^status, date_sent: ^NaiveDateTime.utc_now]]
    ) |> Schedulex.Repo.update_all([])
  end

  @doc """
  Fetch in batches
  Examples

      iex> Schedulex.Models.AppboyAttribute.users_in(table_name, user_ids)
      %Schedulex.Models.AppboyAttribute{}
  """
  @batch_size 50
  def batch_unprocessed_users(tbl) do
    query = from(
      u in {tbl, AppboyAttribute},
      select: u.user_id,
      where: is_nil(u.status)
    )
    stream = EctoBatchStream.stream(Repo, query)
    stream |> Stream.take(@batch_size) |> Enum.to_list
  end
end
