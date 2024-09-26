# frozen_string_literal: true

module FormSubmissionHelper
  FORM_TEMPLATE = <<~ERB.strip_heredoc.squish
    <div id="dragnet-survey-form-<%= survey_id %>"></div>
    <script>
      (function () {
        const script = document.createElement("script");
        script.src = "<%= base_url %>/js/submitter/main.js";
        script.onload = function () {
          dragnet.submitter.shell.initWithNewReply("dragnet-survey-form-<%= survey_id %>", <%= survey_id.to_json %>);
        };
        document.head.append(script);
      }.call(window))
    </script>
  ERB

  def survey_form_code(survey_id, base_url = request.base_url)
    # although arguments seem to not be used, they add 'survey_id' and 'base_url' to lexical binding which is needed in the template
    eval(Erubi::Engine.new(FORM_TEMPLATE).src)
  end
end
