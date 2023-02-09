# frozen_string_literal: true

module WorkspaceHelper
  def survey_qrcode(survey, **svg_opts)
    RQRCode::QRCode.new(reply_to_url(survey.short_id, survey.slug)).as_svg(svg_opts)
  end

  def copy_survey_button(survey)
    icon_button('Copy', survey_copy_path(survey), icon: 'clone', target: "#survey-listing", swap: "beforeend", title: 'Create a copy of this survey', class: 'btn btn-sm btn-secondary')
  end

  def delete_survey_button(survey)
    icon_button('Delete', survey_path(survey), icon: 'trash-can', method: :delete, target: "#survey-#{survey.id}", confirm: "Are you sure you want to delete your survey?", title: 'Delete survey', class: 'btn btn-sm btn-secondary')
  end

  def edit_survey_link(survey)
    icon_link('Edit', edit_survey_path(survey), icon: 'pencil', class: 'btn btn-secondary')
  end

  def survey_preview_link(survey)
    path = reply_to_path(survey.short_id, survey.slug)
    icon_link('Preview Survey', path, icon: 'eye')
  end

  def survey_data_link(survey)
    icon_link('Data', survey_path(survey), icon: 'table')
  end

  def survey_stats_link(survey)
    icon_link('Statistics', survey_stats_path(survey), icon: 'chart-bar')
  end

  def survey_status_indicator(survey, size: 7)
    desc = survey_status_description(survey)
    bgcolor = survey_status_bg_color(survey)

    tag.div(class: "#{bgcolor} d-inline-block", title: desc, style: "width: #{size}px; height: #{size}px; border-radius: 50%;")
  end

  def survey_status_bg_color(survey)
    return 'bg-success' unless survey.edited?
    return 'bg-danger'  unless survey.latest_edit_valid?

    'bg-warning'
  end

  def survey_status_description(survey)
    return 'All changes saved' unless survey.edited?
    return 'Cannot save changes' unless survey.latest_edit_valid?

    'Unsaved changes'
  end
end
