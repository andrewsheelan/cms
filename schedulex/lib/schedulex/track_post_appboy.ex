defmodule Schedulex.TrackPostAppboy do
  @moduledoc """
  Documentation for Schedulex.TrackPostAppboy
  """

  @doc """
  Performs Track Post Appboy task for listener.

  ## Examples

      iex> Exq.enqueue(Exq, "listener", Schedulex.TrackPostAppboy, ["123123-123-123", "tbl_name", [1,2,3,4]])
      {:ok, 7645}

  """
  def perform(appboy_group_id, tbl, user_ids) do
    result = Ecto.Adapters.SQL.query!(Schedulex.Repo, "select user_id, data_type, data_value from #{tbl} where user_id in ($1::array)", [user_ids])
    response = Schedulex.Appboy.send_bulk_attributes(appboy_group_id, result)
    if response.status == 201 do
      result = Ecto.Adapters.SQL.query!(Schedulex.Repo, "update #{tbl} set date_sent=($1) where user_id in ($2::array)", [NaiveDateTime.utc_now, user_ids])
    else
      Exq.enqueue(Exq, "exq", Schedulex.TrackPostAppboy, [appboy_group_id, tbl, user_ids])
    end
  end
end
