# TODO: submit a patch to phlex-rails
module Phlex::Rails::Helpers::Chartkick
  extend Phlex::Rails::HelperMacros
  include Chartkick::Helper

  register_output_helper def line_chart(...) = nil
  register_output_helper def pie_chart(...) = nil
  register_output_helper def column_chart(...) = nil
  register_output_helper def bar_chart(...) = nil
  register_output_helper def area_chart(...) = nil
  register_output_helper def scatter_chart(...) = nil
  register_output_helper def geo_chart(...) = nil
  register_output_helper def timeline_chart(...) = nil
end
