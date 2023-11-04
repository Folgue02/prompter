require "./question"
require "./use_case"
require "./ports"
require "./utils/graphics"

module Prompter::Adapters
  class FileParsingException < Exception
    def initialize(@msg : String, @file : String, @line : UInt32 | Int32)
      super("#{@msg} (#{@file}:#{@line})")
    end
  end

  # In charge of loading the questions from a file.
  class QuestionFileAdapter include Prompter::Ports::QuestionViewOutputPort
    @file_name : String
    def initialize(@file_name : String)
    end

    def fetch_questions : Array(Prompter::Question)
      questions = [] of Prompter::Question

      line_count = 0
      current_prompt : String? = nil
      current_answers = [] of String
      right_answer : Int32? = nil

      File.each_line(@file_name) do |line|
        unless line.empty?

          # Answer
          if is_indented? line
            line = line.strip
            if current_prompt.nil?
              raise FileParsingException.new "Trying to define an answer before defining a question", @file_name, line_count
            end

            if is_right_answer? line
              if !right_answer.nil?
                raise FileParsingException.new "Attempt to define a second right answer for prompt #{current_prompt}", @file_name, line_count
              end

              right_answer = current_answers.size
              line = line[1, line.size]
            end
            current_answers << line
          else # Prompt
            if current_prompt.nil?
              current_prompt = line.strip
            else
              if right_answer.nil?
                raise FileParsingException.new "Cannot finish question without a defined right answer", @file_name, line_count
              end

              questions << Prompter::BasicQuestion.new(current_prompt, current_answers, right_answer.to_u32)
              current_prompt = line.strip
              current_answers = [] of String
              right_answer = nil
            end
          end
        end

        line_count += 1
      end

      questions
    end

    private def is_indented?(line : String) : Bool
      return line.starts_with?(" ") && !line.empty?
    end

    private def is_right_answer?(line : String) : Bool
      return line.strip.starts_with? "@"
    end
  end

  class QuestionCLIAdapter
    @question_use_case : Prompter::UseCase::QuestionViewUseCase
    @file_name : String
    
    def initialize(@file_name : String)
      @question_use_case = Prompter::Ports::QuestionViewInputPort.new(QuestionFileAdapter.new(@file_name))
    end

    private def ask_question(question : Question) : UInt32
      puts "==> #{question.prompt}"
      question.answers.each_with_index do |answer, index|
        puts "#{index + 1}: #{answer}"
      end

      return Prompter::Utils::Graphics.ask_user "Choose an option by typing it's index: ", do |choice|
        choice = choice.to_i rescue nil

        if choice.nil?
          next false
        else
          next choice < 1 || choice > question.answers.size
        end
      end.to_u32
    end

    def prompt : ResultStats
      right_count = 0u32
      start_time = Time.local.millisecond.to_u
      @question_use_case.questions.each do |question|
        choice = ask_question question
        if choice - 1 == question.right_answer
          right_count += 1
        else
          puts "Wrong answer! The right one was #{question.right_answer}"
        end
      end

      end_time = Time.local.millisecond.to_u

      ResultStats.new right_count, @question_use_case.questions.size.to_u32, end_time - start_time
    end

    def prompt_in_shuffle : ResultStats
      # TODO: Shuffle
      prompt
    end
  end
end
