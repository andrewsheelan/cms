defmodule Schedulex.ScheduleTrackAppboy do
  import Inflex
  @moduledoc """
  Documentation for Schedulex.ScheduleTrackAppboy
  """

  @doc """
  Performs Track Post Appboy task for listener.

  ## Examples

      iex> Exq.enqueue(Exq, "scheduler", Schedulex.ScheduleTrackAppboy, ["123123-123-123", "tbl_name", [1,2,3,4]])
      {:ok, 7645}

  """
  def perform(appboy_group_id, tbl, batch_count \\ 10) do
      Enum.each 1..batch_count, fn(f) -> process(appboy_group_id, tbl) end
  end

  defp process(appboy_group_id, tbl) do
    user_ids = Schedulex.Models.AppboyAttribute.batch_unprocessed_users(tbl)
    Schedulex.Appboy.set_status_for_users_in(tbl, user_ids, "COMPLETED")
    Exq.enqueue(
      Exq, "exq", Schedulex.TrackPostAppboy, [appboy_group_id, tbl, user_ids]
    )
  end
  end
end
