# Logic for reply submission
class Dragnet::Reply::Submission < Dragnet::Advice
  advises Reply

  # Mark the reply as submitted
  #
  # @param [Time] timestamp
  #
  # @return [Reply]
  def submitted!(timestamp)
    reply.submitted = true
    reply.submitted_at = timestamp
    reply
  end

  # Apply changes to attributes, validate, mark as submitted and save the reply
  #
  # @param [Hash{Symbol, String => Object}, ActionController::Parameters] attributes
  # @param [Time] timestamp
  #
  # @return [Boolean]
  def submit!(attributes, timestamp: Time.zone.now)
    reply.attributes = attributes
    reply.validate!(:submission)
    submitted!(timestamp)
    reply.save!
  end
end
