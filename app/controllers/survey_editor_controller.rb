# frozen_string_literal: true

class SurveyEditorController < EndpointController
  def show
    respond_to do |format|
      format.transit { render transit: survey_editing.editing_data }
    end
  end

  def update
    edit = new_edit(read_transit(request.body))

    respond_to do |format|
      format.transit { render transit: { edit_id: edit.id, created_at: edit.created_at.to_time } }
    end
  end

  def apply
    edit = latest_edit
    raise "Couldn't find draft to apply" unless edit

    respond_to do |format|
      format.transit do
        if (updated = edit.apply)
          render transit: survey_editing(updated).editing_data
        else
          render transit: edit.application.errors.full_messages, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def survey
    Dragnet::Survey.whole.find(params[:id])
  end

  def latest_edit
    Dragnet::SurveyEdit.latest(survey)
  end

  def new_edit(data)
    Dragnet::SurveyEdit.create_with!(survey, data:)
  end

  def survey_editing(s = survey)
    Dragnet::SurveyEditingPresenter.new(s)
  end
end
