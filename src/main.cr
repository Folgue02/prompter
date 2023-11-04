require "./question"
require "./question_adapter"

question_file_adapter = Prompter::Adapters::QuestionFileAdapter.new(ARGV[0])
cli_adapter = Prompter::Adapters::QuestionCLIAdapter.new ARGV[0]

puts "#{cli_adapter.prompt}"

