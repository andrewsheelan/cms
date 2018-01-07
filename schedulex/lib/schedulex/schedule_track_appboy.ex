defmodule Schedulex.ScheduleTrackAppboy do
  @moduledoc """
  Documentation for Schedulex.ScheduleTrackAppboy
  """

  @doc """
  Performs Track Post Appboy task for listener.

  ## Examples

      iex> Exq.enqueue(Exq, "scheduler", Schedulex.ScheduleTrackAppboy, ["123123-123-123", "tbl_name", [1,2,3,4]])
      {:ok, 7645}

  """
  def perform(args) do
    %{ "appboy_group_id" => appboy_group_id, "table" => tbl, "batch_count" => batch_count} = args
    # appboy_group_id, tbl, batch_count \\ 10
    Enum.each 1..batch_count, fn(_) -> process(appboy_group_id, tbl) end
  end

  defp process(appboy_group_id, tbl) do
    user_ids = Schedulex.Models.AppboyAttribute.batch_unprocessed_users(tbl)
    unless Enum.empty?(user_ids) do
      Exq.enqueue(
        Exq, "appboy", Schedulex.TrackPostAppboy, [appboy_group_id, tbl, user_ids]
      )
      Schedulex.Models.AppboyAttribute.set_status_for_users_in(tbl, user_ids, "QUEUED")
    end
  end
end
