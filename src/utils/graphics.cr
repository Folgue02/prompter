module Prompter::Utils::Graphics
  def self.ask_user(prompt : String? = nil, &is_valid? : String -> Bool) : String
    user_input : String? = nil
    while user_input.nil? || is_valid?.call user_input
      if !prompt.nil?
        print prompt
      end
      
      user_input = STDIN.gets
    end

    user_input
  end
end
