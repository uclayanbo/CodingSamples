## After executing the entire script,
## type play() on the console to start a tic tac toe game.

options(warn = -1)

triples <- list(c(1,2,3), c(4,5,6), c(7,8,9), c(1,4,7), c(2,5,8), c(3,6,9), c(1,5,9), c(3,5,7))

state <- rep(NA, 9)

display <- function(state) {
  d <- c()
  for (i in 1:9) {
    d[i] <- ifelse(is.na(state[i]), i, state[i])}
  
  cat("\n-----------\n")
  cat(" ", d[1], " | ", d[2], " | ", d[3], sep = "")
  cat("\n---+---+---\n")
  cat(" ", d[4], " | ", d[5], " | ", d[6], sep = "")
  cat("\n---+---+---\n")
  cat(" ", d[7], " | ", d[8], " | ", d[9], sep = "")
  cat("\n-----------\n")
}


update <- function(state, who, pos) {
  repeat {repeat {if (pos %in% 1:9 == FALSE) {
    cat("Oops, there are only 9 spots...")
    cat("\nPlease select between 1 and 9.")
    pos <- as.numeric(readline(prompt = "Okay, I will go: "))}
    if (pos %in% 1:9 == TRUE) {break}}

    repeat {if (is.na(state[pos]) == FALSE) {
    cat("Oops, the spot you went has been taken...")
    cat("\nPlease select another spot.")
    pos <- as.numeric(readline(prompt = "Okay, I will go: "))}
    if (is.na(state[pos]) == TRUE) {break}}
    
    if (pos %in% 1:9 == TRUE & is.na(state[pos]) == TRUE) {break}}
  
  state[pos] <- who
  return(state)
}


prompt_user <- function(who) {
  cat("Now, it's '", who, "'s turn!", sep = "")
  cat("\nWhere does '", who, "' want to go?", sep = "")
  input <- as.numeric(readline(prompt = paste("'", who, "' wants to go: ", sep = "")))
  
  repeat {if (input %in% 1:9 == FALSE) {
    cat("Oops, there are only 9 spots...")
    cat("\nPlease select between 1 and 9.")
    input <- as.numeric(readline(prompt = "Okay, I will go: "))}
    if (input %in% 1:9 == TRUE) {break}}
  
  return(input)
}


computer_turn <- function(who, state) {
  computer_strategy <- function(self, opponent, state) {
    d <- c()
    for (i in 1:9) {
      d[i] <- ifelse(is.na(state[i]), i, state[i])}
    # Initial step
    if (all(is.numeric(d))) {return(sample(1:9, 1))}
    # Winning step - priority
    if(d[1] == 1){
      if(d[2] == self & d[3] == self) {return(1)}
      if(d[4] == self & d[7] == self) {return(1)}
      if(d[5] == self & d[9] == self) {return(1)}}
    if(d[2] == 2){
      if(d[1] == self & d[3] == self) {return(2)}
      if(d[5] == self & d[8] == self) {return(2)}}
    if(d[3] == 3){
      if(d[1] == self & d[2] == self) {return(3)}
      if(d[6] == self & d[9] == self) {return(3)}
      if(d[5] == self & d[7] == self) {return(3)}}
    if(d[4] == 4){
      if(d[5] == self & d[6] == self) {return(4)}
      if(d[1] == self & d[7] == self) {return(4)}}
    if(d[5] == 5){
      if(d[1] == self & d[9] == self) {return(5)}
      if(d[2] == self & d[8] == self) {return(5)}
      if(d[3] == self & d[7] == self) {return(5)}
      if(d[4] == self & d[6] == self) {return(5)}}
    if(d[6] == 6){
      if(d[4] == self & d[5] == self) {return(6)}
      if(d[3] == self & d[9] == self) {return(6)}}
    if(d[7] == 7){
      if(d[1] == self & d[4] == self) {return(7)}
      if(d[3] == self & d[5] == self) {return(7)}
      if(d[8] == self & d[9] == self) {return(7)}}
    if(d[8] == 8){
      if(d[2] == self & d[5] == self) {return(8)}
      if(d[7] == self & d[9] == self) {return(8)}}
    if(d[9] == 9){
      if(d[6] == self & d[3] == self) {return(9)}
      if(d[8] == self & d[7] == self) {return(9)}
      if(d[5] == self & d[1] == self) {return(9)}}
    # Blocking step
    if(d[1] == 1){
      if(d[2] == opponent & d[3] == opponent) {return(1)}
      if(d[4] == opponent & d[7] == opponent) {return(1)}
      if(d[5] == opponent & d[9] == opponent) {return(1)}}
    if(d[2] == 2){
      if(d[1] == opponent & d[3] == opponent) {return(2)}
      if(d[5] == opponent & d[8] == opponent) {return(2)}}
    if(d[3] == 3){
      if(d[1] == opponent & d[2] == opponent) {return(3)}
      if(d[5] == opponent & d[7] == opponent) {return(3)}
      if(d[6] == opponent & d[9] == opponent) {return(3)}}
    if(d[4] == 4){
      if(d[1] == opponent & d[7] == opponent) {return(4)}
      if(d[5] == opponent & d[6] == opponent) {return(4)}}
    if(d[5] == 5){
      if(d[1] == opponent & d[9] == opponent) {return(5)}
      if(d[2] == opponent & d[8] == opponent) {return(5)}
      if(d[3] == opponent & d[7] == opponent) {return(5)}
      if(d[4] == opponent & d[6] == opponent) {return(5)}}
    if(d[6] == 6){
      if(d[3] == opponent & d[9] == opponent) {return(6)}
      if(d[4] == opponent & d[5] == opponent) {return(6)}}
    if(d[7]==7){
      if(d[3] == opponent & d[5] == opponent) {return(7)}
      if(d[1] == opponent & d[4] == opponent) {return(7)}
      if(d[8] == opponent & d[9] == opponent) {return(7)}}
    if(d[8] == 8){
      if(d[2] == opponent & d[5] == opponent) {return(8)}
      if(d[7] == opponent & d[9] == opponent) {return(8)}}
    if(d[9] == 9){
      if(d[1] == opponent & d[5] == opponent) {return(9)}
      if(d[3] == opponent & d[6] == opponent) {return(9)}
      if(d[7] == opponent & d[8] == opponent) {return(9)}}
    # Always take the mid if possible
    if(d[5] == 5) {return(5)}
    # Other cases - random step
    else {
      emp <- c()
      for (i in 1:9) {
        if (is.na(state[i])) {emp <- c(emp, i)}
        else {next}}
      return(sample(rep(emp, 2), 1))}
  }
  
  if (who == "x") {computer_strategy("x", "o", state)}
  else {computer_strategy("o", "x", state)}
}


check_winner <- function(state) {
  # checks if there is a winner.
  for (i in 1:length(triples)) {
    if (all(state[triples[[i]]] %in% "x")) {return(1)} # 1 is "x"
    if (all(state[triples[[i]]] %in% "o")) {return(2)}} # 2 is "o"
  return(0) # 0 is ongoing game or draw
}


play <- function() {
  cat("Welcome to Tic-Tac-Toe, Version Yan Bo!!!")
  cat("\nHow many players are there? 1 or 2?")
  player_num <- as.numeric(readline(prompt = "Please type 1 or 2: "))
  
  repeat {if (player_num %in% 1:2 == FALSE) {
    cat("There can be only 1 or 2 players.")
    player_num <- as.numeric(readline(prompt = "Please type 1 or 2: "))}
    if (player_num %in% 1:2) {break}}
  
  while (player_num == 2) {
    cat("Game START!!!\n")
    while (check_winner(state) == 0) {
      i <- 1
      while (i <= 10) {
        if (i == 10) {
          display(state)
          cat("\nMEHHH... It's a draw.")
          break}
        else if (i%%2 != 0) {
          display(state)
          pos_x <- prompt_user("x")
          state <- update(state, "x", pos_x)
          if (check_winner(state) == 1) {
            display(state)
            cat("\nWinner! Winner! Chicken Dinner!")
            cat("\nPlayer 'x' wins!!! YAY!!!")
            break}
          else {i <- i + 1}}
        else {
          display(state)
          pos_o <- prompt_user("o")
          state <- update(state, "o", pos_o)
          if (check_winner(state) == 2) {
            display(state)
            cat("\nWinner! Winner! Chicken Dinner!")
            cat("\nPlayer 'o' wins!!! YAY!!!")
            break}
          else {i <- i + 1}}}
      break}
    break}
  
  while (player_num == 1) {
    cat("\nDo you want to play as 'x' or 'o'?")
    cat("\n'x' always goes first, and 'o' always goes second.")
    x_or_o <- as.character(readline(prompt = "Please type x or o: "))
    
    repeat {if (x_or_o!="x" & x_or_o!="o") {
      cat("Sorry, players can only be 'x' or 'o'.")
      x_or_o <- as.character(readline(prompt = "Please type x or o: "))}
      if (x_or_o=="x" | x_or_o=="o") {break}}
    
    while (x_or_o == "x") {
      cat("Game START!!!\n")
      while (check_winner(state) == 0) {
        i <- 1
        while (i <= 10) {
          if (i == 10) {
            display(state)
            cat("\nMEHHH... It's a draw.")
            break}
          else if (i%%2 != 0) {
            display(state)
            pos_x <- prompt_user("x")
            state <- update(state, "x", pos_x)
            if (check_winner(state) == 1) {
              display(state)
              cat("\nWinner! Winner! Chicken Dinner!")
              cat("\nPlayer 'x' wins!!! YAY!!!")
              break}
            else {i <- i + 1}}
          else {
            display(state)
            pos_o <- computer_turn("o", state)
            state <- update(state, "o", pos_o)
            cat("\nBOT 'o' went ", pos_o, ".\n", sep = "")
            if (check_winner(state) == 2) {
              display(state)
              cat("\nGood Game!")
              cat("\nBOT 'o' wins!!!")
              break}
            else {i <- i + 1}}}
        break}
      break}
    
    while (x_or_o == "o") {
      cat("Game START!!!\n")
      while (check_winner(state) == 0) {
        i <- 1
        while (i <= 10) {
          if (i == 10) {
            display(state)
            cat("\nMEHHH... It's a draw.")
            break}
          else if (i%%2 != 0) {
            display(state)
            pos_x <- computer_turn("x", state)
            state <- update(state, "x", pos_x)
            cat("\nBOT 'x' went ", pos_x, ".\n", sep = "")
            if (check_winner(state) == 1) {
              display(state)
              cat("\nGood Game!")
              cat("\nBOT 'x' wins!!!")
              break}
            else {i <- i + 1}}
          else {
            display(state)
            pos_o <- prompt_user("o")
            state <- update(state, "o", pos_o)
            if (check_winner(state) == 2) {
              display(state)
              cat("\nWinner! Winner! Chicken Dinner!")
              cat("\nPlayer 'o' wins!!! YAY!!!")
              break}
            else {i <- i + 1}}}
        break}
      break}
    break}
}

