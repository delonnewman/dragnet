# Project attributes suitable for ARs `accepts_nested_attributes_for` from
# edit survey data.
#
# @see FormEdit#form_data
# @see Form
# @see Field
# @see FieldOption
class FormEdit::FormAttributeProjection < Dragnet::Advice
  advises FormEdit, as: :edit

  def attributes
    edit.form_data.slice(:id, :name, :author_id, :description).tap do |attrs|
      attrs[:fields_attributes] = field_attributes
    end
  end

  def field_data
    edit.form_data[:fields] || EMPTY_ARRAY
  end

  def field_attributes
    field_data.map do |(_, f)|
      f.slice(*field_keys(f)).tap do |new|
        if f[:field_options].present?
          new[:field_options_attributes] = f[:field_options].map do |(_, opt)|
            opt.slice(*field_option_keys(opt))
          end
        end
      end
    end
  end

  def field_keys(field)
    %i[text display_order required field_type_id _destroy].tap do |keys|
      keys << :id unless field[:id].is_a?(Integer) && field[:id].negative?
    end
  end

  def field_option_keys(option)
    %i[text weight _destroy].tap do |keys|
      keys << :id if option[:id].positive?
    end
  end
end
