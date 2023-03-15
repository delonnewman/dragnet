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

  # @param [Array<Answer>] answers
  #
  # @return [String] html to render the display
  def render(question_type, answers, alt: '-')
    self.question_type = question_type
    method_name = :"render_#{question_type.ident}"

    if respond_to?(method_name)
      public_send(method_name, answers, alt: alt)
    else
      render_default(answers, alt: alt)
    end
  end
end