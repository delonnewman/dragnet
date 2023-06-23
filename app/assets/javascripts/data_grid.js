(function() {

  const dataGridTable = document.querySelector('#data-grid-table')

  dataGridTable.addEventListener('htmx:afterSwap', () => {
    document.querySelectorAll('[autofocus=autofocus]').forEach((elem) => {
      // HACK: set cursor to the end of the input value
      const val = elem.value
      elem.value = ''
      elem.value = val
    })
  })

}.call(window))
