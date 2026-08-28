# frozen_string_literal: true

module Dragnet::Views::Surveys
  class Map < TabbedView
    include Phlex::Rails::Helpers::JavaScriptIncludeTag
    include Phlex::Rails::Helpers::DOMID

    def self.tab_name = 'Map'
    def self.tab_icon_class = 'fas fa-location-dot'
    def self.types = [Dragnet::Ext::Address]

    CODE = <<~JAVASCRIPT
      (function () {
        const createMap = () => { new Mapkick.Map(%s, %s, %s) };
        if ('Mapkick' in window) {
          createMap();
        } else {
          window.addEventListener('mapkick:load', createMap, true);
        }
      }());
    JAVASCRIPT

    def view_template
      id = dom_id(@survey, :map)
      maplibre
      script(src: 'https://unpkg.com/mapkick@0.2.6/dist/mapkick.js')

      div(id:, style: 'height:800px')
      script do
        raw safe(sprintf(CODE, id.to_json, locations.to_json, options.to_json))
      end
    end

    def maplibre
      link(href: 'https://unpkg.com/maplibre-gl@5.24.0/dist/maplibre-gl.css', rel: 'stylesheet')
      script(src: 'https://unpkg.com/maplibre-gl@5.24.0/dist/maplibre-gl.js')
    end

    def mapbox
      link(href: 'https://api.mapbox.com/mapbox-gl-js/v3.25.0/mapbox-gl.css', rel: 'stylesheet')
      script(src: 'https://api.mapbox.com/mapbox-gl-js/v3.25.0/mapbox-gl.js')
      script { raw safe("mapboxgl.accessToken = #{Mapkick.options[:access_token].to_json}") }
    end

    def options
      {
        style: 'https://demotiles.maplibre.org/style.json',
        accessToken: Mapkick.options[:access_token],
      }
    end

    def locations
      question = address_question
      @survey.replies.map do |reply|
        answers = reply.answers_to(question)
        lat = answers.find { it.short_text_value && it.float_value }
        long = answers.find { !it.short_text_value && it.float_value }
        {
          latitude: lat.number_value,
          longitude: long.number_value,
        }
      end
    end

    def address_question
      question = @survey.questions.find { it.type_class <= Dragnet::Ext::Address }
      raise "Could not find a question in survey #{@survey.id} with type Address" unless question

      question
    end
  end
end
