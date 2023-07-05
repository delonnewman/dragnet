window.dragnet = {};

(function() {

  /**
   * Copy the given text to the clipboard, if a tooltipElement is provided display a tooltip once the copy is complete.
   *
   * @param {string} text
   * @param {Element} tooltipElement
   */
  this.copyToClipboard = function(text, tooltipElement) {
    navigator.clipboard.writeText(text).then(() => {
      if (tooltipElement) {
        const tooltip = bootstrap.Tooltip.getOrCreateInstance(tooltipElement, { title: 'Copied!', trigger: 'manual' })
        tooltip.show()
        setTimeout(() => {
          tooltip.hide();
        }, 2000);
      }
    });
  };

  this.initWorkspace = function() {

    // initialize tooltips
    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
    tooltipTriggerList.forEach((el) => new bootstrap.Tooltip(el))

  };

}.call(window.dragnet));

dragnet.initWorkspace();