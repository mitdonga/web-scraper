class GraphqlChannel < ApplicationCable::Channel
  def subscribed
    stream_from "graphql_channel"
    @subscription_ids = []
    puts "New subscription"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    @subscription_ids.each do |sid|
      SprapeSchema.subscriptions.delete_subscription(sid)
    end
    puts "Subscriptions deleted"
  end

  def execute(data)
    puts "DATA in execute: #{data.inspect}"
    result = execute_query(data)

    payload = {
      result: result.subscription? ? { data: nil } : result.to_h,
      more: result.subscription?
    }

    @subscription_ids << context[:subscription_id] if result.context[:subscription_id]

    transmit(payload)
    puts "Subscriptions being sent data"
  end

  private

  def execute_query(data)
    SprapeSchema.execute(
      query: data["query"],
      context: context,
      variables: data["variables"],
      operation_name: data["operationName"]
    )
  end

  def context
    {
      # current_user_id: current_user&.id,
      # current_user: current_user,
      channel: self
    }
  end

end
