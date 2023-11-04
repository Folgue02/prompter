require "./use_case"


module Prompter::Ports
  module QuestionViewOutputPort
    abstract def fetch_questions : Array(Question)
  end

  class QuestionViewInputPort include Prompter::UseCase::QuestionViewUseCase
    @output_port : QuestionViewOutputPort

    def initialize(@output_port : QuestionViewOutputPort)
    end


    def questions : Array(Question)
      @output_port.fetch_questions
    end
  end
end
