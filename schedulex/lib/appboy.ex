defmodule Schedulex.Appboy do
  @moduledoc """
  A module that implements functions for Running all Appboy tasks
  """

  @doc """
  Tracks user attributes in Appboy. external_id is mandatory.

  Examples

      iex> Schedulex.Appboy.track(%{external_id: 10000, first_name: "John", last_name: "Doe"})

      iex> Schedulex.Appboy.track([%{external_id: 10000, first_name: "John", last_name: "Doe"},
                              %{external_id: 10001, first_name: "Joe", last_name: "Doe"}])
  """
  def track(attributes) do
    app_group_id = System.get_env("APPBOY_GROUP_ID")
    # Define your static variables (app group ID, request url)
    request_url = "https://api.appboy.com/users/track"
    # Store the request data as a dictionary
    data = %{
      app_group_id: app_group_id,
      attributes: List.flatten([ attributes ])
    }

    call(request_url, data)
  end

  @doc """
  Tracks user events in Appboy. external_id is user_id.

  Examples

      iex> Schedulex.Appboy.events(["WEIGHT_LOGGED", "WEIGHT_GAINED"], 100000)

  """
  def events(events, external_id) do
    app_group_id = System.get_env("APPBOY_GROUP_ID")
    web_app_id =  System.get_env("APPBOY_WEB_API_KEY")
    # Define your static variables (app group ID, request url)
    request_url = "https://api.appboy.com/users/track"
    # Store the request data as a dictionary
    events_data = for event <- events do
      %{
        time: DateTime.utc_now() |> DateTime.to_iso8601(),
        app_id: web_app_id,
        external_id: external_id,
        name: event
      }
    end
    data = %{
      app_group_id: app_group_id,
      events: events_data
    }
    call(request_url, data)
  end

  @doc """
  Tracks user events in Appboy. external_id is user_id.

  Example
  iex> Schedulex.Appboy.send_bulk_events([%{event: "EVENT1", external_id: 1},%{event: "EVENT2", external_id: 2}])

  """
  def send_bulk_events(app_group_id, params) do
    # Define your static variables (app group ID, request url)
    request_url = "https://api.appboy.com/users/track"
    # Store the request data as a dictionary
    events_data = for event_data <- params do
      %{
        external_id: event_data.user_id,
        name: event_data.event_name
      }
    end
    data = %{
      app_group_id: app_group_id,
      events: events_data
    }
    call(request_url, data)
  end

  @doc """
  Tracks user events in Appboy. external_id is user_id.

  Example
  iex> Schedulex.Appboy.send_bulk_events([%{event: "EVENT1", external_id: 1},%{event: "EVENT2", external_id: 2}])

  """
  def send_bulk_attributes(app_group_id, params) do
    # Define your static variables (app group ID, request url)
    request_url = "https://api.appboy.com/users/track"
    # Store the request data as a dictionary
    attrs = for event_data <- params do
      %{
        :external_id => event_data.user_id,
        event_data.attribute_name => event_data.data_value
      }
    end
    data = %{
      app_group_id: app_group_id,
      attributes: attrs
    }
    IO.inspect data
    call(request_url, data)
  end

  @doc """
  Tracks user campaigns trigger in Appboy in chunks of 50.
  Accepts a list of user ids and campaign_id to be triggered.

  Examples

      iex> Schedulex.Appboy.campaigns([100000, 1002002], "861a0a74-6769-3171-7803")

  """
  def campaign(users_list, campaign_id) do
    IO.inspect users_list, char_lists: :as_lists
    IO.puts to_string(campaign_id)
    app_group_id = System.get_env("APPBOY_GROUP_ID")
    request_url = "https://api.appboy.com/campaigns/trigger/send"
    data = %{
      app_group_id: app_group_id,
      campaign_id: to_string(campaign_id),
      external_user_ids: users_list
    }
    Stream.chunk(users_list,50, 50, [])
      |> Stream.map(&call(request_url, %{data | external_user_ids: &1}))
      |> Stream.run
  end

  defp call(request_url, data) do
    {_, encoded_data} = Poison.encode(data)
    HTTPoison.post(
      request_url,
      encoded_data,
      ["Content-Type": "application/json"]
    )
  end
end
