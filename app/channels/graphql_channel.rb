class GraphqlChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "graphql_channel"
    @subscription_ids = []
    puts "==================== New subscription ====================="
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    @subscription_ids.each do |sid|
      SprapeSchema.subscriptions.delete_subscription(sid)
    end
    puts "==================== Subscriptions deleted ===================="
  end

  def execute(data)
    puts "DATA in execute: #{data}"

		query = data["query"]
		variables = ensure_hash(data["variables"])
		operation_name = data["operationName"]
		context = {
			channel: self
		}

    result = SprapeSchema.execute(
			query: query,
			context: context,
			variables: variables,
			operation_name: operation_name
		)

		puts result

    payload = {
      result: result.to_h,
      more: result.subscription?
    }

    @subscription_ids << context[:subscription_id] if result.context[:subscription_id]

    transmit(payload)
    puts "Subscriptions being sent data"
  end

  private

	def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end
end
