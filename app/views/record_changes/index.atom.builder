atom_feed do |feed|
  feed.title("Record Changes for #{survey.name}")
  feed.updated(record_changes.first.created_at) if record_changes.count > 0

  record_changes.each do |change|
    feed.entry(change.record) do |entry|
      entry.title(change.summary)
      entry.content(change.diff, type: 'html')

      if change.created_by?
        entry.author do |author|
          author.name(change.created_by.name)
        end
      end
    end
  end
end