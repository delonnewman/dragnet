class FormEdit < ApplicationRecord
  belongs_to :form

  serialize :form_data

  advised_by FormEdit::Application, delegating: %i[apply! applied!]
  advised_by FormEdit::FormAttributeProjection, as: :form_attributes, calling: :attributes
end
