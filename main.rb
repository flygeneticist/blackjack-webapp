require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?

set :sessions, true

helpers do
  def take_a_turn (hand)
    @scores = false
    hand << session[:deck].pop
    evaluate_hand(hand)
    erb :game
  end

  def evaluate_hand(cards)
    value = 0
    cards.sort_by {|target| target[1].to_i}.reverse.each do |card|
      if card.include? 'ace' # ACE cards need to determine best choice: 11 or 1
        if (value + 11) <= 21
          value += 11
        elsif (value + 1) <= 21
          value += 1
        else
          value += 1
        end
      elsif card[1].to_i == 0 # face card => 10 pts
        value += 10
      else # normal number => take face value
        value += card[1]
      end
    end
    value
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

post "/" do # set up game vars and the deck
  session[:minbid] = params[:minbid].to_i
  session[:maxbid] = params[:maxbid].to_i
  session[:bankroll] = params[:bankroll].to_i
  session[:playercount] = params[:playercount].to_i
  session[:player] = params[:player]
  session[:wager] = params[:wager].to_i # setup initial wager
  session[:card_faces] = [2,3,4,5,6,7,8,9,10,'jack','queen','king','ace']
  session[:card_suits] = ['clubs','diamonds','hearts','spades']
  session[:deck] = session[:card_suits].product(session[:card_faces])
  session[:deck] = session[:deck].shuffle
  session[:round_counter] = 1 # track # rounds played before refreshing the deck
  redirect "/newround"
end

post "/newround" do
  session[:wager] = params[:wager].to_i
  session[:round_counter] += 1
  if session[:round_counter] = 6
    session[:deck] = session[:card_suits].product(session[:card_faces])
    session[:deck] = session[:deck].shuffle
  end
  redirect "/newround"
end

get "/newround" do
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
  @scores = false
  erb :game
end

post "/game/player/hit" do
  take_a_turn(session[:player_hand])
  if evaluate_hand(session[:player_hand]) > 21
    @error = session[:player]
    session[:player_buttons] = false
    session[:player_finalvalue] = evaluate_hand(session[:player_hand])
    redirect "/game/settle"
  end
  erb :game
end

post "/game/player/stay" do
  session[:player_finalvalue] = evaluate_hand(session[:player_hand])
  session[:player_stand] = true
  session[:player_buttons] = false
  if session[:player_hand].length == 2 && session[:player_finalvalue] == 21
      @scores = "Blackjack!"
      session[:wager] = (1.5 * session[:wager])
      session[:bankroll] += session[:wager]
      redirect "/game/settle"
  else
      redirect "/game/dealer"
  end
end

get "/game/dealer" do
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
  if @scores && @scores != "Blackjack!"
    if session[:dealer_finalvalue] > 21 && session[:player_finalvalue] <= 21
      @player_results, @dealer_results = "won", "busted"
      session[:bankroll] += session[:wager]
    elsif session[:player_finalvalue] > 21
      @player_results, @dealer_results = "busted and lost", "won"
      session[:bankroll] -= session[:wager]
    else
      if session[:dealer_finalvalue] > session[:player_finalvalue]
        @player_results, @dealer_results = "lost", "won"
        session[:bankroll] -= session[:wager]
      elsif session[:dealer_finalvalue] < session[:player_finalvalue]
        @player_results, @dealer_results = "won", "lost"
        session[:bankroll] += session[:wager]
      else
        @player_results, @dealer_results = "tied the dealer and pushed for", "tied #{session[:player]}"
      end
    end
  end
  erb :game
end
