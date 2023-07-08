class MakeRepliesVisitable < ActiveRecord::Migration[7.0]
  def change
    add_reference :replies, :ahoy_visit
  end
end
