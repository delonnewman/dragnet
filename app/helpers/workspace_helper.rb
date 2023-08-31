# frozen_string_literal: true

module WorkspaceHelper
  # TODO: make the switch work
  def survey_open_indicator(survey)
    htmx = {
      'hx-post'    => survey.open? ? survey_close_path(survey) : survey_open_path(survey),
      'hx-vals'    => { authenticity_token: authenticity_token }.to_json,
      'hx-target'  => "#survey-card-#{survey.id}",
      'hx-swap'    => 'outerHTML',
      'hx-trigger' => 'change',
    }

    tag.div(class: 'd-flex align-items-center ms-2 me-2') do
      form_switch(id: "survey-#{survey.id}-open", input_attributes: { checked: survey.open?, **htmx }, label_attributes: { style: "width:18px" }) do
        icon('fas', survey.open? ? 'lock-open' : 'lock', class: 'text-muted')
      end
    end
  end

  def survey_preview_button(title:, width:, height:, icon: title.downcase)
    tag.button(
      script: 'on click set #preview-frame.width to @data-width then set #preview.height to @data-height',
      class:  'btn btn-primary',
      title:  "#{title} #{width}x#{height}",
      data:   { width: width, height: width }
    ) { icon('fas', icon) }
  end

  EARTH_REGIONS = %w[americas europe asia oceania africa].freeze

  def survey_public_indicator(survey)
    label = survey.public? ? 'Public' : 'Private'

    icon('fas', survey.public? ? "earth-#{EARTH_REGIONS.sample}" : 'key') +
      '&nbsp;'.html_safe + label
  end

  def survey_share_dropdown(survey, align_menu_end: false, tooltip_target: "#survey-card-#{survey.id}")
    reply_url = reply_to_url(survey.short_id, survey.slug)

    tag.div(class: 'dropdown me-1') do
      concat tag.a(class: 'btn btn-sm btn-secondary dropdown-toggle', href: '#', role: 'button', data: { bs_toggle: 'dropdown' }) {
        icon('fas', 'share') + '&nbsp;Share'.html_safe
      }

      concat tag.ul(class: "dropdown-menu #{'dropdown-menu-end' if align_menu_end}") {
        concat tag.li(class: 'dropdown-item', onclick: "dragnet.copyToClipboard('#{reply_url}', '#{tooltip_target}')") { 'Copy Link' }
        concat tag.li { tag.a(class: 'dropdown-item', href: "mailto:?body=#{reply_url}") { 'Email' } }
      }
    end
  end

  def survey_share_modal_button(survey) end

  def copy_survey_button(survey, include_label: false)
    icon_button(
      include_label ? 'Duplicate' : nil, survey_copy_path(survey),
      icon:  'clone',
      title: 'Duplicate this survey',
      data:  { bs_toggle: 'tooltip' },
      class: 'btn btn-sm btn-outline-secondary me-1'
    )
  end

  def delete_survey_button(survey)
    icon_button(
      survey_path(survey),
      icon:    'trash-can',
      method:  :delete,
      target:  "#survey-#{survey.id}",
      confirm: 'Are you sure you want to delete your survey?',
      title:   'Delete this survey',
      data:    { bs_toggle: 'tooltip' },
      class:   'btn btn-sm btn-outline-danger'
    )
  end

  def edit_survey_link(survey, include_label: false)
    icon_link(
      include_label ? 'Edit' : nil, edit_survey_path(survey),
      icon:  'hammer',
      class: 'btn btn-sm btn-outline-secondary me-1',
      data:  { bs_toggle: 'tooltip' },
      title: 'Edit survey'
    )
  end

  def survey_preview_link(survey)
    icon_link('Preview Survey', survey_preview_path(survey), icon: 'eye')
  end

  def survey_data_link(survey)
    icon_link('Records', survey_data_path(survey), icon: 'table')
  end

  def survey_summary_link(survey)
    icon_link('Summary', survey_path(survey), icon: 'gauge')
  end

  def survey_status_indicator(survey, size: 7, include_label: false)
    desc    = survey_status_description(survey)
    bgcolor = survey_status_bg_color(survey)

    tag.div(class: 'd-flex justify-content-between align-items-center') do
      tag.div(class: "#{bgcolor} d-inline-block me-1",
              data:  { bs_toggle: 'tooltip', bs_title: desc, bs_placement: 'top' },
              title: desc,
              style: "width: #{size}px; height: #{size}px; border-radius: 50%;") +
        (include_label ? tag.small(class: 'text-muted') { desc } : '')
    end
  end

  def survey_status_bg_color(survey)
    return 'bg-success' if survey.edits_saved?
    return 'bg-danger' if survey.edits_cannot_save?

    'bg-warning'
  end

  def survey_status_description(survey)
    return 'All changes published' if survey.edits_saved?
    return 'Cannot publish changes' if survey.edits_cannot_save?

    'Unpublished changes'
  end

  def survey_copy_of_link(survey)
    return unless survey.copy?

    tag.small(class: 'text-muted fw-normal') do
      'Copy of&nbsp;'.html_safe +
        if survey.copy_of.author_id == current_user.id
          link_to(survey.copy_of.name, survey_path(survey.copy_of), class: 'text-muted')
        else
          survey.copy_of.name
        end
    end
  end

  METHODS = {
    created_at:           'Created',
    updated_at:           'Updated',
    latest_submission_at: 'Replied to'
  }.freeze
  private_constant :METHODS

  def survey_activity_time_ago(survey)
    times       = survey_activity_times(survey)
    most_recent = times.max_by(&:second).first

    "#{METHODS[most_recent]} #{time_ago_in_words(times[most_recent])} ago"
  end

  def survey_activity_times(survey)
    METHODS.keys.each_with_object({}) do |m, h|
      value = survey.public_send(m)
      h[m]  = value if value
    end
  end
end