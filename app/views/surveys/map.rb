# frozen_string_literal: true

module Dragnet::Views::Surveys
  class Map < TabbedView
    include Phlex::Rails::Helpers::JavaScriptIncludeTag
    include Phlex::Rails::Helpers::DOMID

    LIBRARIES = {
      maplibre: {
        css: 'https://unpkg.com/maplibre-gl@5.24.0/dist/maplibre-gl.css',
        js: 'https://unpkg.com/maplibre-gl@5.24.0/dist/maplibre-gl.js',
        options: {
          style: 'https://demotiles.maplibre.org/style.json',
        },
      },
      mapbox: {
        css: 'https://api.mapbox.com/mapbox-gl-js/v3.25.0/mapbox-gl.css',
        js: 'https://api.mapbox.com/mapbox-gl-js/v3.25.0/mapbox-gl.js',
        options: {
          accessToken: Mapkick.options[:access_token],
        },
      },
    }.freeze

    def self.tab_name = 'Map'
    def self.tab_icon_class = 'fas fa-location-dot'
    def self.types = [Dragnet::Ext::Address]
    def self.path(survey, context) = context.survey_map_path(survey)

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
      id  = dom_id(@survey, :map)
      lib = render_library(:mapbox)
      script(src: 'https://unpkg.com/mapkick@0.2.6/dist/mapkick.js')

      div(id:, style: 'height:800px')
      script do
        options = lib.fetch(:options)
        raw safe(sprintf(CODE, id.to_json, locations.to_json, options.to_json))
      end
    end

    def locations
      question = address_question

      @survey.replies.map do |reply|
        reply.value(question).to_h
      end
    end

    def address_question
      question = @survey.questions
                   .find { it.type_class <= Dragnet::Ext::Address }

      unless question
        raise 'Could not find a question in survey ' \
              "#{@survey.id} with type Address"
      end

      question
    end

    private

    def render_library(lib_name)
      lib = LIBRARIES.fetch(lib_name)
      link(href: lib.fetch(:css), rel: 'stylesheet')
      script(src: lib.fetch(:js))
      lib
    end
  end
end
