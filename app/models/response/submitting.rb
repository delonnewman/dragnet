# Logic for reply submission
class Response::Submitting < Dragnet::Advice
  advises Response, as: :res

  # Mark the reply as submitted
  #
  # @return [Response]
  def submitted(timestamp = Time.now)
    res.submitted = true
    res.submitted_at = timestamp
    res
  end

  # Apply changes to attributes, validate, and mark the reply as submitted
  #
  # @return [Response]
  def submitted!(attributes, timestamp = Time.now)
    res.attributes = attributes
    res.validate!(:submission)
    submitted(timestamp)
  end

  # Apply changes to attributes, validate, mark as submitted and save the reply
  #
  # @return [Boolean]
  def submit!(attributes, timestamp = Time.now)
    submitted!(attributes, timestamp).save!
  end
end
