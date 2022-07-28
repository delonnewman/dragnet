# Logic for reply submission
class Reply::Submission < Dragnet::Advice
  advises Reply

  # Mark the reply as submitted
  #
  # @return [Reply]
  def submitted(timestamp = Time.now)
    reply.submitted = true
    reply.submitted_at = timestamp
    reply
  end

  # Apply changes to attributes, validate, and mark the reply as submitted
  #
  # @return [Reply]
  def submitted!(attributes, timestamp = Time.now)
    reply.attributes = attributes
    reply.validate!(:submission)
    submitted(timestamp)
  end

  # Apply changes to attributes, validate, mark as submitted and save the reply
  #
  # @return [Boolean]
  def submit!(attributes, timestamp = Time.now)
    submitted!(attributes, timestamp).save!
  end
end
