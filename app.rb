require 'sinatra'
require 'sinatra/reloader' if development?

enable :sessions

get '/' do
  if session[:word].nil?
    redirect to('/new')
  end

  redirect to('/win') if won?
  redirect to('/lose') if lost?

  update_instance_variables
  erb :main
end

get '/new' do
  new_game
  redirect to('/')
end

get '/win' do
  redirect to('/') unless won?

  update_instance_variables
  erb :win
end

get '/lose' do
  redirect to('/') unless lost?

  update_instance_variables
  erb :lose
end

post '/try' do
  letter = params[:letter].downcase

  unless already_guessed?(letter)
    session[:try] << letter

    unless good_guess?(letter)
      session[:guesses] -= 1
    end
  end

  redirect to('/')
end

private

def new_game
  session[:word]      = sample_word
  session[:try]       = []
  session[:guesses]   = 7
end

def update_instance_variables
  @word         = session[:word]
  @guesses      = session[:guesses]
  @try          = session[:try]
  @try_string   = try_display_string
  @guess_string = guess_display_string
end

def lost?
  session[:guesses] == 0
end

def won?
  word_array.all?{ |letter| session[:try].include?(letter) }
end

def already_guessed?(letter)
  session[:try].include?(letter)
end

def good_guess?(letter)
  word_array = session[:word].split('')

  return word_array.include?(letter)
end

def guess_display_string
  display_array = []
  word_array.each do |letter|
    if session[:try].include?(letter)
      display_array << letter
    else
      display_array << '_'
    end
  end
  display_array.join(' ')
end

def try_display_string
  session[:try].join(', ')
end

def word_array
  session[:word].split('')
end

def sample_word
  words = []
  File.open('./public/5desk.txt').readlines.each do |line|
    words << line
  end

  words = words.select{ |word| word.length.between?(5,12) }
  words.sample.chomp.downcase
end
