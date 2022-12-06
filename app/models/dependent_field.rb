class DependentField < Field
  belongs_to :field
  belongs_to :field_option
end
