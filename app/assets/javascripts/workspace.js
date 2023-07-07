window.dragnet = {};

(function() {

  /**
   * Copy the given text to the clipboard, if a tooltipElement is provided display a tooltip once the copy is complete.
   *
   * @param {string} text
   * @param {Element} tooltipElement
   *
   * @return {void}
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

  const TOAST_OPTIONS = Object.freeze({ autohide: true, animation: true, delay: 2000 });

  /**
   * Perform initialization for workspace components. Currently this includes initializing tooltips and toasts.
   *
   * @return {void}
   */
  this.initWorkspace = function() {
    // initialize tooltips
    const tooltipTriggers = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    tooltipTriggers.forEach((el) => new bootstrap.Tooltip(el));
    console.debug('Tooltips initialized', tooltipTriggers);

    // initialize toasts
    const toastElements = document.querySelectorAll('.toast');
    toastElements.forEach((el) => {
      const toast = new bootstrap.Toast(el, TOAST_OPTIONS);
      setTimeout(() => {
        toast.hide();
      }, TOAST_OPTIONS.delay);
    });
    console.debug('Toasts initialized', toastElements);
  };

}.call(window.dragnet));

dragnet.initWorkspace();