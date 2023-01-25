--HARDWARE SETUP
--6x6 advanced monitor
--main advanced computer placed under monitors
--timer advanced computer placed to the left of main advanced computer
--2x4 advanced monitor placed anywhere and connected to timer computer


--TODO
--https://en.wikipedia.org/wiki/Descriptive_notation
--Add castling
--Add en passant
--Add pawn promotion
--Add check logic and check mate auto end
--Add forfieting
--Make timers on other computer **toggled by redstone output from main
--Make win screen and fireworks
--Add sound effects
--Add extras
--ADD COMMENTS HOLY SHIT

local inspect = require 'inspect'

function setup()

  extras=false

  surface = dofile("surface")
  monitor = peripheral.wrap("top")
  monitor.setTextScale(0.5)
  term.redirect(monitor)
  width, height = term.getSize()
  screen = surface.create(width, height,colors.white)

  player_1_time=180
  player1="W"
  player_2_time=180
  player2="B"

  board=surface.load("images/board.nfp")
  selection=surface.load("images/selection.nfp")
  pawn_white = surface.load("images/w_pawn.nfp")
  select_pawn_white=surface.load("images/w_pawn_select.nfp")
  pawn_black = surface.load("images/b_pawn.nfp")
  rook_white = surface.load("images/w_rook.nfp")
  rook_black = surface.load("images/b_rook.nfp")
  knight_white = surface.load("images/w_knight.nfp")
  knight_black = surface.load("images/b_knight.nfp")
  bishop_white = surface.load("images/w_bishop.nfp")
  bishop_black = surface.load("images/b_bishop.nfp")
  king_white = surface.load("images/w_king.nfp")
  king_black = surface.load("images/b_king.nfp")
  queen_white=surface.load("images/w_queen.nfp")
  queen_black=surface.load("images/b_queen.nfp")

  squares={
    {10,15},{10,30},{10,45},{10,60},{10,76},{10,91},{10,106},{10,121},
    {20,15},{20,30},{20,45},{20,60},{20,76},{20,91},{20,106},{20,121},
    {30,15},{30,30},{30,45},{30,60},{30,76},{30,91},{30,106},{30,121},
    {40,15},{40,30},{40,45},{40,60},{40,76},{40,91},{40,106},{40,121},
    {51,15},{51,30},{51,45},{51,60},{51,76},{51,91},{51,106},{51,121},
    {61,15},{61,30},{61,45},{61,60},{61,76},{61,91},{61,106},{61,121},
    {71,15},{71,30},{71,45},{71,60},{71,76},{71,91},{71,106},{71,121},
    {81,15},{81,30},{81,45},{81,60},{81,76},{81,91},{81,106},{81,121}
  }
  memory={
    {"Brook","Bknight","Bbishop","Bqueen","Bking","Bbishop","Bknight","Brook"},
    {"Bpawn","Bpawn","Bpawn","Bpawn","Bpawn","Bpawn","Bpawn","Bpawn"},
    {"X","X","X","X","X","X","X","X"},
    {"X","X","X","X","X","X","X","X"},
    {"X","X","X","X","X","X","X","X"},
    {"X","X","X","X","X","X","X","X"},
    {"Wpawn","Wpawn","Wpawn","Wpawn","Wpawn","Wpawn","Wpawn","Wpawn"},
    {"Wrook","Wknight","Wbishop","Wqueen","Wking","Wbishop","Wknight","Wrook"}
  }
end

function indexOf(object,t)
    for i=1,8 do
      for j=1,8 do
        if memory[i][j]==object then return i,j end
      end
    end
end

function board_refresh()
  screen:clear(colors.black)
  screen:drawSurface(board,0,0,width,height)
  screen:output()
end

function memory_update(old_x,old_y,x,y)

  --the ifs are for castling check
  if memory[old_y][old_x]=="Wrook" then
    memory[y][x]="WrookM"
    memory[old_y][old_x]="X"

  elseif memory[old_y][old_x]=="Brook" then
    memory[y][x]="BrookM"
    memory[old_y][old_x]="X"

  elseif memory[old_y][old_x]=="Wking" then
    memory[y][x]="WkingM"
    memory[old_y][old_x]="X"

  elseif memory[old_y][old_x]=="Bking" then
    memory[y][x]="BkingM"
    memory[old_y][old_x]="X"
  else
    temp=memory[old_y][old_x]
    memory[y][x]=temp
    memory[old_y][old_x]="X"  
  end
end

function pieces_setup()
  for i=1,8 do
    if i==1 or i==8 then
      screen:drawSurface(rook_white,squares[i][2]-10,squares[8*8][1]-6)
      screen:drawSurface(rook_black,squares[i][2]-10,squares[8*1][1]-8)
    elseif i==2 or i==7 then
      screen:drawSurface(knight_white,squares[i][2]-10,squares[8*8][1]-6)
      screen:drawSurface(knight_black,squares[i][2]-10,squares[8*1][1]-8) 
    elseif i==3 or i==6 then
      screen:drawSurface(bishop_white,squares[i][2]-10,squares[8*8][1]-6)
      screen:drawSurface(bishop_black,squares[i][2]-10,squares[8*1][1]-8)
    elseif i==5 then
      screen:drawSurface(king_white,squares[i][2]-10,squares[8*8][1]-6)
      screen:drawSurface(king_black,squares[i][2]-10,squares[8*1][1]-8)
    elseif i==4 then
      screen:drawSurface(queen_white,squares[i][2]-10,squares[8*8][1]-6)
      screen:drawSurface(queen_black,squares[i][2]-10,squares[8*1][1]-8)
    end
    screen:drawSurface(pawn_white,(squares[i][2])-10,(squares[8*7][1])-6)
    screen:drawSurface(pawn_black,(squares[i][2])-10,(squares[8*2][1])-7)
    screen:output()
  end
end

function fix_square_color(x,y)
  if y%2==0 and x%2~=0 or y%2~=0 and x%2==0 then
    if x==5 and y~=5 then
      screen:drawRect((squares[x][2])-16, (squares[y*8][1])-10, 16, 10,colors.black)
    elseif y==5 and x~=5 then
      screen:drawRect((squares[x][2])-15, (squares[y*8][1])-11, 15, 11,colors.black)
    elseif y==5 and x==5 then
      screen:drawRect((squares[x][2])-16, (squares[y*8][1])-11, 16, 11,colors.black)
    else
      screen:drawRect((squares[x][2])-15,(squares[y*8][1])-10,15,10,colors.black)
    end
  elseif y%2~=0 and x%2~=0 or y%2==0 and x%2==0 or y==x then
    if x==5 and y~=5 then
      screen:drawRect((squares[x][2])-16, (squares[y*8][1])-10, 16, 10,colors.white)
    elseif y==5 and x~=5 then
      screen:drawRect((squares[x][2])-15, (squares[y*8][1])-11, 15, 11,colors.white)
    elseif y==5 and x==5 then
      screen:drawRect((squares[x][2])-16, (squares[y*8][1])-11, 16, 11,colors.white)
    else
      screen:drawRect((squares[x][2])-15,(squares[y*8][1])-10,15,10,colors.white)
    end
  end
end

function square_refresh(x,y)
  if y%2==0 and x%2~=0 or y%2~=0 and x%2==0 then
    if x==5 and y~=5 then
      screen:fillRect((squares[x][2])-16, (squares[y*8][1])-10, 16, 10,colors.black)
    elseif y==5 and x~=5 then
      screen:fillRect((squares[x][2])-15, (squares[y*8][1])-11, 15, 11,colors.black)
    elseif y==5 and x==5 then
      screen:fillRect((squares[x][2])-16, (squares[y*8][1])-11, 16, 11,colors.black)
    else
      screen:fillRect((squares[x][2])-15,(squares[y*8][1])-10,15,10,colors.black)
    end
  elseif y%2~=0 and x%2~=0 or y%2==0 and x%2==0 or y==x then
    if x==5 and y~=5 then
      screen:fillRect((squares[x][2])-16, (squares[y*8][1])-10, 16, 10,colors.white)
    elseif y==5 and x~=5 then
      screen:fillRect((squares[x][2])-15, (squares[y*8][1])-11, 15, 11,colors.white)
    elseif y==5 and x==5 then
      screen:fillRect((squares[x][2])-16, (squares[y*8][1])-11, 16, 11,colors.white)
    else
      screen:fillRect((squares[x][2])-15,(squares[y*8][1])-10,15,10,colors.white)
    end
  end
  screen:output()
end

function update_piece(old_x,old_y,x,y)
  square_refresh(old_x,old_y)
  square_refresh(x,y)
  if memory[y][x]=="Wpawn" then
    screen:drawSurface(pawn_white,(squares[x][2])-10,(squares[8*y][1])-6)
  elseif memory[y][x]=="Bpawn" then
    screen:drawSurface(pawn_black,(squares[x][2])-10,(squares[8*y][1])-6)
  elseif memory[y][x]=="Brook" or memory[y][x]=="BrookM" then
    screen:drawSurface(rook_black,(squares[x][2])-10,(squares[8*y][1])-6)
  elseif memory[y][x]=="Wrook" or memory[y][x]=="WrookM" then
    screen:drawSurface(rook_white,(squares[x][2])-10,(squares[8*y][1])-6)
  elseif memory[y][x]=="Bknight" then
    screen:drawSurface(knight_black,(squares[x][2])-10,(squares[8*y][1])-6)
  elseif memory[y][x]=="Wknight" then
    screen:drawSurface(knight_white,(squares[x][2])-10,(squares[8*y][1])-6)
  elseif memory[y][x]=="Bbishop" then
    screen:drawSurface(bishop_black,(squares[x][2])-10,(squares[8*y][1])-6)
  elseif memory[y][x]=="Wbishop" then
    screen:drawSurface(bishop_white,(squares[x][2])-10,(squares[8*y][1])-6)
  elseif memory[y][x]=="Wking" or memory[y][x]=="WkingM" then
    screen:drawSurface(king_white,(squares[x][2])-10,(squares[8*y][1])-6)
  elseif memory[y][x]=="Bking" or memory[y][x]=="BkingM" then
    screen:drawSurface(king_black,(squares[x][2])-10,(squares[8*y][1])-6)
  elseif memory[y][x]=="Wqueen" then
    screen:drawSurface(queen_white,(squares[x][2])-10,(squares[8*y][1])-6)
  elseif memory[y][x]=="Bqueen" then
    screen:drawSurface(queen_black,(squares[x][2])-10,(squares[8*y][1])-6)
  end
  screen:output()
end

function is_piece(x,y)
  if memory[y][x]=="X" then
    return false
  else
    return true
  end
end

function what_color(x,y)
  if string.sub(memory[y][x],1,1)=="B" then
    return "B"
  elseif string.sub(memory[y][x],1,1)=="W" then
    return "W"
  else
    return "empty"
  end
end

function is_opponent(x,y,turn)
  if is_piece(x,y)==true then
    if turn=="W" then
      if string.sub(memory[y][x],1,1)=="B" then
        return true
      else
        return false
      end
    else
      if string.sub(memory[y][x],1,1)=="W" then
        return true
      else
        return false
      end
    end
  end
end

function is_check(turn)
  --check if king square is a valid move for an opponents piece // if true then check // if all valid squares for king to move are check then checkmate
  x,y=indexOf("Wking",memory)
  
  for i=1,8 do
      for j=1,8 do
        if is_valid_move(i,j,x,y,turn) then
          print("check")
        end
      end
  end

end

function timer(turn)
  --sends redstone signal to start timer on other computer
end

function is_valid_move(old_x,old_y,x,y,turn)
  
  if memory[old_y][old_x]=="Wpawn" then
    if old_y-1<=y and old_x==x and memory[y][x]=="X" and memory[old_y-1][old_x]=="X" then
      return true
    elseif old_y-1==y and (old_x+1==x or old_x-1==x) and is_opponent(x,y,"W")==true then
      return true
    elseif old_y-2<=y and old_x==x and memory[y][x]=="X" and memory[old_y-1][old_x]=="X" and old_y==7 then
      return true
    else
      return false
    end
  
  elseif memory[old_y][old_x]=="Bpawn" then
    if old_y+1>=y and old_x==x and memory[y][x]=="X" and memory[old_y+1][old_x]=="X" then
      return true
    elseif old_y+1==y and (old_x+1==x or old_x-1==x) and is_opponent(x,y,"B")==true then
      return true
    elseif old_y-2<=y and old_x==x and memory[y][x]=="X" and memory[old_y+1][old_x]=="X" and old_y==2 then
      return true
    else
      return false
    end
  
  elseif string.sub(memory[old_y][old_x],2,5)=="rook" then
    count=0
    step=1
    if old_y>y or old_x>x then
        step=-1
    end
    if old_y==y and (memory[y][x]=="X" or is_opponent(x,y,turn)==true) then  
      for i=old_x+step,x,step do
        if memory[y][i]~="X" then
          count=count+1
        end
      end
      if count==1 and is_opponent(x,y,turn)==true then
          return true
      elseif count==0 then
        return(true)
      else
        return(false)
      end
    elseif old_x==x and (memory[y][x]=="X" or is_opponent(x,y,turn)==true) then
      for i=old_y+step,y,step do
        if memory[i][x]~="X" then
          count=count+1
        end
      end
      if count==1 and is_opponent(x,y,turn)==true then
          return true
      elseif count==0 then
        return(true)
      else
        return(false)
      end
    else
      return false
    end

  elseif string.sub(memory[old_y][old_x],2,7)=="knight" then
    if (old_y-2==y or old_y+2==y) and (old_x+1==x or old_x-1==x) and (memory[y][x]=="X" or is_opponent(x,y,turn)==true) then
      return true
    elseif (old_y-1==y or old_y+1==y) and (old_x+2==x or old_x-2==x) and (memory[y][x]=="X" or is_opponent(x,y,turn)==true) then
      return true
    else
      return false
    end

  elseif string.sub(memory[old_y][old_x],2,7)=="bishop" then
    check=0
    y_check=false
    x_check=false
    total=math.abs(old_y-y)
    if old_x>x then
        x_check=true
    end
    if old_y>y then
        y_check=true
    end
    if (math.abs(old_y-y)==math.abs(old_x-x)) and (memory[y][x]=="X" or is_opponent(x,y,turn)==true) then
      if x_check==true and y_check==true then
        for i=1,total,1 do
          test1=old_y-i
          test2=old_x-i
          if memory[test1][test2]~="X" then
            check=check+1
          end
        end
      elseif x_check==false and y_check==false then
        for i=1,total,1 do
          test1=old_y+i
          test2=old_x+i
          if memory[test1][test2]~="X" then
            check=check+1
          end
        end
      elseif x_check==false and y_check==true then
        for i=1,total,1 do
          test1=old_y-i
          test2=old_x+i
          if memory[test1][test2]~="X" then
            check=check+1
          end
        end
      elseif x_check==true and y_check==false then
        for i=1,total,1 do
          test1=old_y+i
          test2=old_x-i
          if memory[test1][test2]~="X" then
            check=check+1
          end
        end
      end
      if check==1 and is_opponent(x,y,turn)==true then
        return true
      elseif check==0 then
        return(true)
      else
        return(false)
      end
    else
      return false
    end

  elseif string.sub(memory[old_y][old_x],2,6)=="queen" then
    check=0
    y_check=false
    x_check=false
    total=math.abs(old_y-y)
    if old_x>x then
        x_check=true
    end
    if old_y>y then
        y_check=true
    end
    count=0
    step=1
    if old_y>y or old_x>x then
        step=-1
    end

    if (math.abs(old_y-y)==math.abs(old_x-x)) and (memory[y][x]=="X" or is_opponent(x,y,turn)==true) then
      if x_check==true and y_check==true then
        for i=1,total,1 do
          test1=old_y-i
          test2=old_x-i
          if memory[test1][test2]~="X" then
            check=check+1
          end
        end
      elseif x_check==false and y_check==false then
        for i=1,total,1 do
          test1=old_y+i
          test2=old_x+i
          if memory[test1][test2]~="X" then
            check=check+1
          end
        end
      elseif x_check==false and y_check==true then
        for i=1,total,1 do
          test1=old_y-i
          test2=old_x+i
          if memory[test1][test2]~="X" then
            check=check+1
          end
        end
      elseif x_check==true and y_check==false then
        for i=1,total,1 do
          test1=old_y+i
          test2=old_x-i
          if memory[test1][test2]~="X" then
            check=check+1
          end
        end
      end
      if check==1 and is_opponent(x,y,turn)==true then
        return true
      elseif check==0 then
        return(true)
      else
        return(false)
      end
    
    elseif old_y==y and (memory[y][x]=="X" or is_opponent(x,y,turn)==true) then  
      for i=old_x+step,x,step do
        if memory[y][i]~="X" then
          count=count+1
        end
      end
      if count==1 and is_opponent(x,y,turn)==true then
          return true
      elseif count==0 then
        return(true)
      else
        return(false)
      end
    
    elseif old_x==x and (memory[y][x]=="X" or is_opponent(x,y,turn)==true) then
      for i=old_y+step,y,step do
        if memory[i][x]~="X" then
          count=count+1
        end
      end
      if count==1 and is_opponent(x,y,turn)==true then
          return true
      elseif count==0 then
        return(true)
      else
        return(false)
      end
    else
      return false
    end

  elseif string.sub(memory[old_y][old_x],2,5)=="king" then
    if ((math.abs(old_y-y) == math.abs(old_x-x)) or (math.abs(old_y-y)==1 and old_x==x) or (math.abs(old_x-x)==1 and old_y==y)) and (memory[y][x]=="X" or is_opponent(x,y,turn)==true) then
      return true
    --need check logic before castle logic
    --elseif then
      --return true
    
    else  
      return false
    end
  end


end

function player_selection(turn)
  flag=0
  old_x=1
  old_y=1
  repeat
    if flag==1 and is_piece(x,y)==true and what_color(x,y)==turn then
      old_x=x
      old_y=y
      fix_square_color(old_x,old_y)
    end
    event, side, xPos, yPos = os.pullEvent("monitor_touch") 
    x=math.floor(xPos/15)+1
    y=math.ceil(yPos/10)
    if y==9 then
      y=8
    end
    if is_piece(x,y)==true and what_color(x,y)==turn then
      if x==5 and y~=5 then
        screen:drawRect((squares[x][2])-16, (squares[y*8][1])-10, 16, 10,colors.red)
        flag=1
      elseif y==5 and x~=5 then
        screen:drawRect((squares[x][2])-15, (squares[y*8][1])-11, 15, 11,colors.red)
        flag=1
      elseif y==5 and x==5 then
        screen:drawRect((squares[x][2])-16, (squares[y*8][1])-11, 16, 11,colors.red)
        flag=1
      else
        screen:drawRect((squares[x][2])-15,(squares[y*8][1])-10,15,10,colors.red)
        flag=1
      end
      screen:output()
    end
  until((is_piece(x,y)==false and is_piece(old_x,old_y)==true and flag==1 and is_valid_move(old_x,old_y,x,y,turn)==true and what_color(old_x,old_y)==turn) or (is_opponent(x,y,turn)==true and is_piece(old_x,old_y)==true and flag==1 and is_valid_move(old_x,old_y,x,y,turn)==true and what_color(old_x,old_y)==turn))
  memory_update(old_x,old_y,x,y)
  update_piece(old_x,old_y,x,y)
end

function test()

  board_refresh()
  pieces_setup()
  while true do
    --print(indexOf("WkingM",memory))
    player_selection(player1)
    player_selection(player2)
    --print(inspect(memory))
  end
end

setup()
test()
