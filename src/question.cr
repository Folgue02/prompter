module Prompter
  abstract class Question
    property answers : Array(String), prompt : String, right_answer : UInt32

    def initialize(@prompt : String, @answers : Array(String), @right_answer : UInt32)
    end

    abstract def is_right?(answer : UInt32) : Bool

    def to_s : String
      String.build do |builder|
        builder << @prompt
        
        @answers.each_with_index do |answer, index|
          if index == @right_answer
            builder << " @#{answer}"
          else
            builder << " #{answer}"
          end
          builder << "\n"
        end
      end
    end
  end

  class BasicQuestion < Question
    def is_right?(answer : UInt32) : Bool
      answer == @right_answer
    end
  end

  class ResultStats
    property right_answers : UInt32, total : UInt32, total_time : UInt32

    def initialize(@right_answers : UInt32, @total : UInt32, @total_time : UInt32)
    end

    def percentage : Float64
      percent = @total / 100
      @right_answers / percent
    end

    def time_per_question : Float64
      @total_time / @total
    end

    def to_s
      "Total right answers: #{@right_answers}/#{@total} (#{percentage}%)\nTotal time: #{@total_time/1000}\nAverage time per question: #{time_per_question}"
    end
  end
end
