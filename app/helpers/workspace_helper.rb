# frozen_string_literal: true

module WorkspaceHelper
  def survey_qrcode(survey, **svg_opts)
    RQRCode::QRCode.new(reply_to_url(survey.short_id, survey.slug)).as_svg(svg_opts)
  end

  # TODO: make the switch work
  def survey_open_indicator(survey)
    tag.div(class: 'd-flex align-items-center') do
      form_switch(id: "survey-#{survey.id}-open") do
        icon('fas', survey.open? ? 'lock-open' : 'lock', class: 'text-muted')
      end
    end
  end

  def survey_preview_button(title:, icon: title.downcase, width:, height:)
    tag.button(
      script: "on click set #preview-frame.width to @data-width then set #preview.height to @data-height",
      class: "btn btn-secondary",
      title: "#{title} #{width}x#{height}",
      data: { width: width, height: width }) do
        icon('fas', icon)
    end
  end

  EARTH_REGIONS = %w[americas europe asia oceania africa].freeze

  def survey_public_indicator(survey)
    label = survey.public? ? 'Public' : 'Private'

    icon('fas', survey.public? ? "earth-#{EARTH_REGIONS.sample}" : 'key') +
      '&nbsp;'.html_safe + label
  end

  def survey_share_dropdown(survey, align_menu_end: false)
    tag.div(class: 'dropdown me-1') do
      tag.a(class: 'btn btn-sm btn-secondary dropdown-toggle', href: '#', role: 'button', data: { bs_toggle: 'dropdown' }) {
        icon('fas', 'share') + '&nbsp;Share'.html_safe
      } + tag.ul(class: "dropdown-menu #{'dropdown-menu-end' if align_menu_end}") {
        tag.li(class: 'dropdown-item') { 'Copy Link' }
      }
    end
  end

  def copy_survey_button(survey, include_label: false)
    icon_button(include_label ? 'Copy' : nil, survey_copy_path(survey),
                icon: 'clone',
                title: 'Copy survey',
                class: 'btn btn-sm btn-outline-secondary me-1')
  end

  def delete_survey_button(survey)
    icon_button(survey_path(survey),
                icon: 'trash-can',
                method: :delete,
                target: "#survey-#{survey.id}",
                confirm: "Are you sure you want to delete your survey?",
                title: 'Delete survey',
                class: 'btn btn-sm btn-outline-danger')
  end

  def edit_survey_link(survey, include_label: false)
    icon_link(include_label ? 'Edit' : nil, edit_survey_path(survey),
              icon: 'hammer',
              class: 'btn btn-sm btn-outline-secondary me-1',
              title: 'Edit survey')
  end

  def survey_preview_link(survey)
    icon_link('Preview Survey', survey_preview_path(survey), icon: 'eye')
  end

  def survey_data_link(survey)
    icon_link('Records', survey_data_path(survey), icon: 'table')
  end

  def survey_stats_link(survey)
    icon_link('Statistics', survey_stats_path(survey.short_id), icon: 'chart-column')
  end

  def survey_status_indicator(survey, size: 7, include_label: false)
    desc = survey_status_description(survey)
    bgcolor = survey_status_bg_color(survey)

    tag.div(class: 'd-flex justify-content-between align-items-center') do
      tag.div(class: "#{bgcolor} d-inline-block me-1",
              title: desc,
              style: "width: #{size}px; height: #{size}px; border-radius: 50%;") +
        (include_label ? tag.small(class: 'text-muted') { desc } : '')
    end
  end

  def survey_status_bg_color(survey)
    return 'bg-success' if survey.edits_saved?
    return 'bg-danger'  if survey.edits_cannot_save?

    'bg-warning'
  end

  def survey_status_description(survey)
    return 'All changes saved' if survey.edits_saved?
    return 'Cannot save changes' if survey.edits_cannot_save?

    'Unsaved changes'
  end

  def survey_copy_of_link(survey)
    return unless survey.copy?

    tag.small(class: "text-muted fw-normal") do
      "Copy of&nbsp;".html_safe +
        if survey.copy_of.author_id == current_user.id
          link_to(survey.copy_of.name, survey_path(survey.copy_of), class: 'text-muted')
        else
          survey.copy_of.name
        end
    end
  end
end
