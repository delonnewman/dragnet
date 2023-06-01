# TODO: move this to lib, make contexts subclasses, and support arbitrary polymorphic methods, not just "render"
class ApplicationPerspective
  include ActionView::Helpers::TagHelper

  class << self
    def question_type(type, &block)
      @_question_type = type.is_a?(Symbol) ? type : type.ident
      class_eval(&block)
      @_question_type = nil
    end
    alias context question_type

    def method_added(method_name)
      if @_question_type
        new_name = :"#{method_name}_#{@_question_type}"
        @_question_type = nil
        alias_method(new_name, method_name)
        remove_method(method_name)
      end
    end
  end

  attr_reader :context
  delegate :output_buffer=, :output_buffer, to: :@context, allow_nil: true

  attr_accessor :question_type
  private :question_type=

  # TODO: make a view perspective subclass that takes a context, move "render" code there
  def initialize(context)
    @context = context
  end

  def render_default(answers, alt: '-')
    if answers.present?
      answers.join(', ')
    else
      alt
    end
  end

  # @param [QuestionType] question_type
  #
  # @return [String] html to render the display
  def render(question_type, *args, **options)
    self.question_type = question_type
    method_name = :"render_#{question_type.ident}"

    if respond_to?(method_name)
      public_send(method_name, *args, **options)
    else
      render_default(*args, **options)
    end
  end
end