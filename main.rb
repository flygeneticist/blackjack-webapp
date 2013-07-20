require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?

set :sessions, true

helpers do
  def take_a_turn (hand)
    hand << session[:deck].pop
    evaluate_hand(hand)
    check_for_special_hand(hand)
    erb :game
  end

  def evaluate_hand(cards)
    value = 0
    cards.sort_by {|target| target[1].to_i}.each do |card|
      if card.include? 'ace' # ACE cards need to determine best choice: 11 or 1
        if (value + 11) <= 21
          value += 11
        elsif (value + 1) <= 21
          value += 1
        else
          @error = session[:player]
        end
      elsif card[1].to_i == 0 # face card => 10 pts
        value += 10
      else # normal number => take face value
        value += card[1]
      end
    end
    value
  end

  def check_for_special_hand (cards)
    # the checks below are special for the first turn only (2 cards)
    if cards.length == 2 && evaluate_hand(cards) == 21
      "Blackjack!"
    end
  end
end

get "/" do
  erb :home
end

get "/about" do
  erb :about
end

get "/rules" do
  erb :rules
end

get "/contact" do
  erb :contact
end

get "/botwarning" do
  erb :botwarning
end

get '/logout' do # clear cookies after game is ended
  session.clear
  redirect "/"
end

post "/load" do # set up game vars and the deck
  session[:minbid] = params[:minbid]
  session[:maxbid] = params[:maxbid]
  session[:bankroll] = params[:bankroll]
  session[:playercount] = params[:playercount]
  session[:player] = params[:player]
  redirect "/newround"
end

get "/newround" do
  card_faces = [2,3,4,5,6,7,8,9,10,'jack','queen','king','ace']
  card_suits = ['clubs','diamonds','hearts','spades']
  session[:deck] = card_suits.product(card_faces)
  session[:deck] = session[:deck].shuffle
  session[:dealer_hand] = []
  session[:player_hand] = []
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop
  session[:player_stand] = false
  session[:dealer_stand] = false
  session[:player_buttons] = true
  session[:dealer_finalvalue] = 0
  session[:player_finalvalue] = 0
  redirect "/game"
end

get "/game" do
  erb :game
end

post "/game/player/hit" do
  take_a_turn(session[:player_hand])
  if evaluate_hand(session[:player_hand]) > 21
    @error = session[:player]
  end
  erb :game
end

post "/game/player/stay" do
  session[:player_finalvalue] = evaluate_hand(session[:player_hand])
  session[:player_stand] = true
  session[:player_buttons] = false
  redirect "/game/dealer"
end

get "/game/dealer" do
  sleep 0.5
  if evaluate_hand(session[:dealer_hand]) < 17
    redirect "/game/dealer/hit"
  elsif evaluate_hand(session[:dealer_hand]) >= 17 && evaluate_hand(session[:dealer_hand]) <= 21
    session[:dealer_stand] = true
    session[:dealer_finalvalue] = evaluate_hand(session[:dealer_hand])
    redirect "/game/settle"
  end
  redirect "/game/settle"
end

get "/game/dealer/hit" do
  take_a_turn(session[:dealer_hand])
  if evaluate_hand(session[:dealer_hand]) > 21
    @error = session[:dealer]
  end
  erb :game
  redirect "/game/dealer"
end

get "/game/settle" do
  @scores = true
  if session[:dealer_finalvalue] > 21 && session[:player_finalvalue] <= 21
    @player_results, @dealer_results = "won", "busted"
  elsif session[:dealer_finalvalue] <= 21 && session[:player_finalvalue] > 21
    @player_results, @dealer_results = "busted", "won"
  else
    if session[:dealer_finalvalue] > session[:player_finalvalue]
      @player_results, @dealer_results = "lost", "won"
    elsif session[:dealer_finalvalue] < session[:player_finalvalue]
      @player_results, @dealer_results = "won", "lost"
    else
      @player_results, @dealer_results = "tied the dealer", "tied #{session[:player]}"
    end
  end
  erb :game
end
