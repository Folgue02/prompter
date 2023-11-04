require "./question"

module Prompter::UseCase
  module QuestionViewUseCase
    abstract def questions : Array(Question)
    def questions_in_shuffle : Array(Question)
      questions.shuffle
    end
  end
end
