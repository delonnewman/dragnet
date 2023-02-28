module ApplicationHelper
  def javascripts
    @javascripts ||= []
  end

  def sparklines(data, width: 100, height: 50)
    id = "sparkline-#{data.hash}"
    javascripts << "sparkline(document.querySelector('##{id}'), #{data.to_json})".html_safe
    tag.svg(class: 'sparkline', id: id, width: width, height: height, 'stroke-width': 3)
  end
end
