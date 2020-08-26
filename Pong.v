
// This module is designed for 640x480 with a 25 MHz input clock.
// All test patterns are being generated all the time.  This makes use of one
// of the benefits of FPGAs, they are highly parallelizable.  Many different
// things can all be happening at the same time.  In this case, there are several
// test patterns that are being generated simulatenously.  The actual choice of
// which test pattern gets displayed is done via the i_Pattern signal, which is
// an input to a case statement.


// Note: Comment out this line when building in iCEcube2:
//`include "Sync_To_Count.v"

//`include "Debounce_Switch.v"

module Pong
  #(parameter VIDEO_WIDTH = 3,
   parameter TOTAL_COLS  = 800,
   parameter TOTAL_ROWS  = 525,
   parameter ACTIVE_COLS = 640,
   parameter ACTIVE_ROWS = 480)
  
  
  //the i_VSync and i_HSync come from the output of VGA_Sync_Pulses
  //NOTICE the o_Red_Video 
  (input       i_Clk,
   input       i_HSync,
   input       i_VSync,
   input       i_Sw1,
   input       i_Sw2,
   input       i_Sw3,
   input       i_Sw4,
   output reg  o_HSync = 0,
   output reg  o_VSync = 0,
   output reg [VIDEO_WIDTH-1:0] o_Red_Video,
   output reg [VIDEO_WIDTH-1:0] o_Grn_Video,
   output reg [VIDEO_WIDTH-1:0] o_Blu_Video,
   output reg [3:0] o_Game_Test
   );
  
  wire w_VSync;
  wire w_HSync;
  
  //paddle and ball params and regs
  parameter c_LEFT_PONG_PADDLE_LEFT_SIDE = 18;
  parameter c_LEFT_PONG_PADDLE_RIGHT_SIDE  = 28;
  parameter c_RIGHT_PONG_PADDLE_LEFT_SIDE = 510;
  parameter c_RIGHT_PONG_PADDLE_RIGHT_SIDE  = 520;
  parameter c_PONG_PADDLE_HEIGHT = 48;
  parameter c_BALL_RADIUS = 6;
  
  reg [9:0] r_Height_Left_Paddle = 100;

  reg [9:0] r_Height_Right_Paddle = 422;

  reg [9:0] r_Ball_X_Coord = 320;

  reg [9:0] r_Ball_Y_Coord = 240;
  
  reg [27:0] r_Ball_Can_Increment = 0;
	
  //tally mark params and regs 
  parameter c_INCREMENT_TALLY_MARK = 5;
  parameter c_TALLY_MARK_WIDTH = 2;
  parameter c_TALLY_MARK_TOP_Y_COORD = 10;
  parameter c_TALLY_MARK_BOTTOM_Y_COORD = 20;
  parameter c_PLAYER_1_X_COORD_FIRST_TALLY = 100;
  parameter c_PLAYER_2_X_COORD_FIRST_TALLY = 400; 
  
  reg [2:0] r_Tally_Player_One = 0;
  
  reg [2:0] r_Tally_Player_Two = 0;
  
  
  reg [3:0] r_4_Increments_Left = 0;

  reg [3:0] r_4_Increments_Right = 0;  
 

  //for the Delta registers below regarding delta
  //let 0 be negative and 1 be positive
  reg [1:0] r_Ball_Delta_X = 1;

  reg [1:0] r_Ball_Delta_Y = 1;

  wire w_Switch_1;

  wire w_Switch_2;

  wire w_Switch_3;

  wire w_Switch_4;


  reg [23:0] r_Left_Paddle_Can_Move_Up = 0;

  reg [23:0] r_Left_Paddle_Can_Move_Down = 0;

  reg [23:0] r_Right_Paddle_Can_Move_Up = 0;

  reg [23:0] r_Right_Paddle_Can_Move_Down = 0;


  reg [2:0] r_Switch_1_Pressed_3_Times_To_Start_Game = 0;

  reg [1:0] r_Game_Started = 0;

  reg [1:0] r_Freeze_Game = 0;

  reg [3:0] r_Game_Test = 0;

  //here we keep track of switches being pressed
  //which changes how we render the pong paddles
  //switches 1 and 2 affect the left paddle (1 is up 2 is down)
  //switches 3 and 4 affect the right paddle (3 is up 4 is down)

  always @(posedge i_Clk)
    begin 
      
      if(r_Game_Started == 1 )
        begin
          r_Game_Test <= 4'b1111;
          if(i_Sw1 == 1'b1)
            begin
              
              r_Left_Paddle_Can_Move_Up <= r_Left_Paddle_Can_Move_Up + 1;
              if(r_Left_Paddle_Can_Move_Up == 250000 && r_Height_Left_Paddle - 4 > 0)
                begin
                  r_Height_Left_Paddle <= r_Height_Left_Paddle - 4;
                  r_Left_Paddle_Can_Move_Up <= 0;
                  if(r_Height_Left_Paddle - 4 <= 0)
                    r_4_Increments_Left <= r_4_Increments_Left + 1;
                end
              else if(r_Left_Paddle_Can_Move_Up > 250000)
              	r_Left_Paddle_Can_Move_Up <= 0;
            end

        end
      else
        begin
          if(r_Switch_1_Pressed_3_Times_To_Start_Game < 3)
            if(i_Sw1 == 1)
              begin
                  begin
                      r_Switch_1_Pressed_3_Times_To_Start_Game <= r_Switch_1_Pressed_3_Times_To_Start_Game + 1;
                    if(r_Switch_1_Pressed_3_Times_To_Start_Game  + 1  == 3'b011)
                          r_Game_Started <= 1'b1;
                  end
              end 
        end  
         if(r_Game_Started == 1)
        begin
          
          if(i_Sw2 == 1'b1) 
            begin
              
              r_Left_Paddle_Can_Move_Down <= r_Left_Paddle_Can_Move_Down + 1;
              if(r_Left_Paddle_Can_Move_Down == 250000 && (r_Height_Left_Paddle + c_PONG_PADDLE_HEIGHT + 4) < ACTIVE_ROWS)
                begin
                  r_Height_Left_Paddle <= r_Height_Left_Paddle + 4;
                  r_Left_Paddle_Can_Move_Down <= 0;
                end
              else if(r_Left_Paddle_Can_Move_Down > 250000)
              	r_Left_Paddle_Can_Move_Down <= 0;
            end
        end



          if(i_Sw3 == 1'b1)
            begin
              
              r_Right_Paddle_Can_Move_Up <= r_Right_Paddle_Can_Move_Up + 1;
              if(r_Right_Paddle_Can_Move_Up == 250000 && r_Height_Right_Paddle - 4 > 0)
                begin
                  r_Height_Right_Paddle <= r_Height_Right_Paddle - 4;
                  r_Right_Paddle_Can_Move_Up <= 0;
                end
              else if(r_Right_Paddle_Can_Move_Up > 250000)
              	r_Right_Paddle_Can_Move_Up <= 0;
            end
		if(r_Game_Started == 1)  
        begin


          if(i_Sw4 == 1'b1) 
            begin
              
              r_Right_Paddle_Can_Move_Down <= r_Right_Paddle_Can_Move_Down + 1;
              if(r_Right_Paddle_Can_Move_Down == 250000 && (r_Height_Right_Paddle + c_PONG_PADDLE_HEIGHT + 4) < ACTIVE_ROWS)
                begin
                  r_Height_Right_Paddle <= r_Height_Right_Paddle + 4;
                  r_Right_Paddle_Can_Move_Down <= 0;
                end
              else if(r_Right_Paddle_Can_Move_Down > 250000)
              	r_Right_Paddle_Can_Move_Down <= 0;
            end

        end        
    end

  // always @(posedge i_Clk)
  //   begin 
  //     if(r_Game_Started == 1)
  //       begin
          
  //         if(i_Switch_2 == 1'b1) 
  //           begin
  //             r_Left_Paddle_Can_Move_Down <= r_Left_Paddle_Can_Move_Down + 1;
  //             if(r_Left_Paddle_Can_Move_Down == 10 && (r_Height_Left_Paddle + c_PONG_PADDLE_HEIGHT + 4) < ACTIVE_ROWS)
  //               begin
  //                 r_Height_Left_Paddle <= r_Height_Left_Paddle + 4;
  //                 r_Left_Paddle_Can_Move_Down <= 0;
  //               end
  //             else if(r_Left_Paddle_Can_Move_Down > 10)
  //             	r_Left_Paddle_Can_Move_Down <= 0;
  //           end
  //       end
  //   end  
      

  // always @(posedge i_Clk)
  //   begin 
  //     if(r_Game_Started == 1)  
  //       begin

  //         if(i_Switch_3 == 1'b1)
  //           begin
  //             r_Right_Paddle_Can_Move_Up <= r_Right_Paddle_Can_Move_Up + 1;
  //             if(r_Right_Paddle_Can_Move_Up == 10 && r_Height_Right_Paddle - 4 > 0)
  //               begin
  //                 r_Height_Right_Paddle <= r_Height_Right_Paddle - 4;
  //                 r_Right_Paddle_Can_Move_Up <= 0;
  //               end
  //             else if(r_Right_Paddle_Can_Move_Up > 10)
  //             	r_Right_Paddle_Can_Move_Up <= 0;
  //           end
  //       end
  //   end  

  // always @(posedge i_Clk)
  //   begin 
  //     if(r_Game_Started == 1)  
  //       begin


  //         if(i_Switch_4 == 1'b1) 
  //           begin
  //             r_Right_Paddle_Can_Move_Down <= r_Right_Paddle_Can_Move_Down + 1;
  //             if(r_Right_Paddle_Can_Move_Down == 10 && (r_Height_Right_Paddle + c_PONG_PADDLE_HEIGHT + 4) < ACTIVE_ROWS)
  //               begin
  //                 r_Height_Right_Paddle <= r_Height_Right_Paddle + 4;
  //                 r_Right_Paddle_Can_Move_Down <= 0;
  //               end
  //             else if(r_Right_Paddle_Can_Move_Down > 10)
  //             	r_Right_Paddle_Can_Move_Down <= 0;
  //           end

  //       end
  //   end
  always @(posedge i_Clk)
    begin 
      r_Ball_Can_Increment <= r_Ball_Can_Increment + 1;
      if(r_Freeze_Game == 0 && r_Ball_Can_Increment == 100000)
        begin
          r_Ball_Can_Increment <= 0;
          if(r_Ball_Delta_X == 0 && r_Ball_Delta_Y == 0)
            begin
              if((r_Ball_X_Coord - 1 <= c_LEFT_PONG_PADDLE_RIGHT_SIDE && r_Ball_X_Coord - 1 >= c_LEFT_PONG_PADDLE_RIGHT_SIDE - 2) && r_Ball_Y_Coord - 1 !== 0 && r_Ball_Y_Coord >= r_Height_Left_Paddle && r_Ball_Y_Coord - 5 <= r_Height_Left_Paddle + c_PONG_PADDLE_HEIGHT )
                  begin
                    r_Ball_Delta_X <= 1;
                    r_Ball_X_Coord <= r_Ball_X_Coord + 2;
                    r_Ball_Y_Coord <= r_Ball_Y_Coord - 1;
                  end  
              else if(r_Ball_Y_Coord - 1 == 0 && r_Ball_X_Coord - 1 !== c_LEFT_PONG_PADDLE_RIGHT_SIDE)
                  begin
                    r_Ball_Delta_Y <= 1;
                    r_Ball_Y_Coord <= r_Ball_Y_Coord + 1;
                    r_Ball_X_Coord <= r_Ball_X_Coord - 2;
                  end
                else if((r_Ball_X_Coord - 1 <= c_LEFT_PONG_PADDLE_RIGHT_SIDE && r_Ball_X_Coord - 1 >= c_LEFT_PONG_PADDLE_RIGHT_SIDE - 2) && r_Ball_Y_Coord - 1 == 0 && r_Ball_Y_Coord >= r_Height_Left_Paddle && r_Ball_Y_Coord - 5 <= r_Height_Left_Paddle + c_PONG_PADDLE_HEIGHT)
                  begin
                    r_Ball_Delta_X <= 1;
                    r_Ball_Delta_Y <= 1;
                    r_Ball_X_Coord <= r_Ball_X_Coord + 2;
                    r_Ball_Y_Coord <= r_Ball_Y_Coord + 1;
                  end
                  else
                    begin
                      r_Ball_X_Coord <= r_Ball_X_Coord - 2;
                      r_Ball_Y_Coord <= r_Ball_Y_Coord - 1;
                    end
            end
          if(r_Ball_Delta_X == 1 && r_Ball_Delta_Y == 0)
            begin
              if((r_Ball_X_Coord + 1 >= c_RIGHT_PONG_PADDLE_LEFT_SIDE && r_Ball_X_Coord + 1 <= c_RIGHT_PONG_PADDLE_LEFT_SIDE + 2) && r_Ball_Y_Coord - 1 !== 0 && r_Ball_Y_Coord >= r_Height_Right_Paddle && r_Ball_Y_Coord - 5 <= r_Height_Right_Paddle + c_PONG_PADDLE_HEIGHT )
                  begin
                    r_Ball_Delta_X <= 0;
                    r_Ball_X_Coord <= r_Ball_X_Coord - 2;
                    r_Ball_Y_Coord <= r_Ball_Y_Coord - 1;
                  end  
              else if(r_Ball_Y_Coord - 1 == 0 && r_Ball_X_Coord + 1 !== c_RIGHT_PONG_PADDLE_LEFT_SIDE)
                  begin
                    r_Ball_Delta_Y <= 1;
                    r_Ball_X_Coord <= r_Ball_X_Coord + 2;
                    r_Ball_Y_Coord <= r_Ball_Y_Coord + 1;
                  end
              else if((r_Ball_X_Coord - 1 >= c_RIGHT_PONG_PADDLE_LEFT_SIDE && r_Ball_X_Coord - 1 <= c_RIGHT_PONG_PADDLE_LEFT_SIDE + 2) && r_Ball_Y_Coord - 1 == 0 && r_Ball_Y_Coord >= r_Height_Right_Paddle && r_Ball_Y_Coord - 5 <= r_Height_Right_Paddle + c_PONG_PADDLE_HEIGHT)
                  begin
                    r_Ball_Delta_X <= 0;
                    r_Ball_Delta_Y <= 1;
                    r_Ball_X_Coord <= r_Ball_X_Coord - 2;
                    r_Ball_Y_Coord <= r_Ball_Y_Coord + 1;
                  end
                else
                    begin
                      r_Ball_X_Coord <= r_Ball_X_Coord + 2;
                      r_Ball_Y_Coord <= r_Ball_Y_Coord - 1;
                    end  
            end
          if(r_Ball_Delta_X == 0 && r_Ball_Delta_Y == 1)
            begin
              if((r_Ball_X_Coord - 1 <= c_LEFT_PONG_PADDLE_RIGHT_SIDE && r_Ball_X_Coord - 1 >= c_LEFT_PONG_PADDLE_RIGHT_SIDE - 2) && r_Ball_Y_Coord + 1 !== ACTIVE_ROWS && r_Ball_Y_Coord >= r_Height_Left_Paddle && r_Ball_Y_Coord - 5 <= r_Height_Left_Paddle + c_PONG_PADDLE_HEIGHT )
                  begin
                    r_Ball_Delta_X <= 1;
                    r_Ball_X_Coord <= r_Ball_X_Coord + 2;
                    r_Ball_Y_Coord <= r_Ball_Y_Coord + 1;
                  end  
              else if(r_Ball_Y_Coord + 1 == ACTIVE_ROWS && r_Ball_X_Coord - 1 !== c_LEFT_PONG_PADDLE_RIGHT_SIDE)
                  begin
                    r_Ball_Delta_Y <= 0;
                    r_Ball_X_Coord <= r_Ball_X_Coord - 2;
                    r_Ball_Y_Coord <= r_Ball_Y_Coord - 1;
                  end
                else if((r_Ball_X_Coord - 1 <= c_LEFT_PONG_PADDLE_RIGHT_SIDE && r_Ball_X_Coord - 1 >= c_LEFT_PONG_PADDLE_RIGHT_SIDE - 2) && r_Ball_Y_Coord + 1 == ACTIVE_ROWS && r_Ball_Y_Coord >= r_Height_Left_Paddle && r_Ball_Y_Coord - 5 <= r_Height_Left_Paddle + c_PONG_PADDLE_HEIGHT)
                  begin
                    r_Ball_Delta_X <= 1;
                    r_Ball_Delta_Y <= 0;
                    r_Ball_X_Coord <= r_Ball_X_Coord + 2;
                    r_Ball_Y_Coord <= r_Ball_Y_Coord - 1;
                  end
                else
                    begin
                      r_Ball_X_Coord <= r_Ball_X_Coord - 2;
                      r_Ball_Y_Coord <= r_Ball_Y_Coord + 1;
                    end  
            end
          if(r_Ball_Delta_X == 1 && r_Ball_Delta_Y == 1)
            begin
              if((r_Ball_X_Coord + 2 >= c_RIGHT_PONG_PADDLE_LEFT_SIDE && r_Ball_X_Coord + 2 <= c_RIGHT_PONG_PADDLE_LEFT_SIDE + 2) && r_Ball_Y_Coord + 1 !== ACTIVE_ROWS && r_Ball_Y_Coord >= r_Height_Right_Paddle && r_Ball_Y_Coord - 5 <= r_Height_Right_Paddle + c_PONG_PADDLE_HEIGHT )
                  begin
                    r_Ball_Delta_X <= 0;
                    r_Ball_X_Coord <= r_Ball_X_Coord - 2;
                    r_Ball_Y_Coord <= r_Ball_Y_Coord + 1;
                  end  
              else if(r_Ball_Y_Coord + 1 == ACTIVE_ROWS && r_Ball_X_Coord + 1 !== c_RIGHT_PONG_PADDLE_LEFT_SIDE)
                  begin
                    r_Ball_Delta_Y <= 0;
                    r_Ball_X_Coord <= r_Ball_X_Coord + 2;
                    r_Ball_Y_Coord <= r_Ball_Y_Coord - 1;
                  end
              else if((r_Ball_X_Coord + 2 <= c_LEFT_PONG_PADDLE_RIGHT_SIDE && r_Ball_X_Coord + 2 >= c_LEFT_PONG_PADDLE_RIGHT_SIDE - 2) && r_Ball_Y_Coord + 1 == ACTIVE_ROWS && r_Ball_Y_Coord >= r_Height_Right_Paddle && r_Ball_Y_Coord - 5 <= r_Height_Right_Paddle + c_PONG_PADDLE_HEIGHT)
                  begin
                    r_Ball_Delta_X <= 0;
                    r_Ball_Delta_Y <= 0;
                    r_Ball_X_Coord <= r_Ball_X_Coord - 2;
                    r_Ball_Y_Coord <= r_Ball_Y_Coord - 1;
                  end
                else
                    begin
                      r_Ball_X_Coord <= r_Ball_X_Coord + 2;
                      r_Ball_Y_Coord <= r_Ball_Y_Coord + 1;
                    end  
            end
          if(r_Ball_X_Coord == 0 || r_Ball_X_Coord == ACTIVE_COLS)
            begin
            	//r_Freeze_Game <= 1;  
              if(r_Ball_X_Coord == 0) 
               	begin
              		r_Tally_Player_Two <= r_Tally_Player_Two + 1;
                  if(r_Tally_Player_Two + 1 == 5)
                    begin
                      r_Tally_Player_One <= 0;   
                      r_Tally_Player_Two <= 0;
                      r_Ball_X_Coord <= 320;
  					         r_Ball_Y_Coord <= 240;
                      r_Ball_Delta_X <= 0;
	                  r_Ball_Delta_Y <= 0;
                    end
                  else
                    begin
                      r_Ball_X_Coord <= 320;
  					  r_Ball_Y_Coord <= 240;
                      r_Ball_Delta_X <= 0;
	                  r_Ball_Delta_Y <= 0;
                    end
                  
                end
              else if(r_Ball_X_Coord ==  ACTIVE_COLS)
                begin
                  r_Tally_Player_One <= r_Tally_Player_One + 1;
                  if(r_Tally_Player_One + 1 == 5)
                    begin
                      r_Tally_Player_One <= 0;   
                      r_Tally_Player_Two <= 0;
                      r_Ball_X_Coord <= 320;
  					  r_Ball_Y_Coord <= 240;
                      r_Ball_Delta_X <= 1;
                      r_Ball_Delta_Y <= 0;
                    end
                  else
                    begin
                      r_Ball_X_Coord <= 320;
  					  r_Ball_Y_Coord <= 240;
                      r_Ball_Delta_X <= 1;
	                  r_Ball_Delta_Y <= 0;
                    end
                end
            end 
       end
    end
  

  

  // Patterns have 16 indexes (0 to 15) and can be g_Video_Width bits wide
  //the patterns are an array of values 
  //THESE ARE A UNIQUE STYLE OF DATA
  //THEY ARE A 3 bit vector net with a depth of 16
  //THIS MEANS we have 16 total elements in the array that are 
  //all 3 bits long so for instance 
  //{111, 000, 111, 111, 111 ...} etc but 16 of them total
  //i think russel left this as 0:15 so that 
  //we can create our own patterns if we want,
  //or perhaps for pong
  wire [VIDEO_WIDTH-1:0] Pattern_Red[0:15];
  wire [VIDEO_WIDTH-1:0] Pattern_Grn[0:15];
  wire [VIDEO_WIDTH-1:0] Pattern_Blu[0:15];
  
  // Make these unsigned counters (always positive)
  wire [9:0] w_Col_Count;
  wire [9:0] w_Row_Count;

  wire [6:0] w_Bar_Width;
  wire [2:0] w_Bar_Select;
  
  //integer i = 0;
  
  //here we have our sync to count module 
  //but it almost seems as if though we aren't instantiating the module,
  //but rather we are saving it as a variable?
  //interesting, we feed the same input i_VSync and i_HSync 
  //to the Sync_To_Count module
  //we feed our wires w_VSync and w_HSync to the Sync_To_Count module..
  //but why.....?
  //why would we need feedback from Sync_To_Count
  //it's not clear why this is here.... 
  //but whatever
  Sync_To_Count #(.TOTAL_COLS(TOTAL_COLS),
                  .TOTAL_ROWS(TOTAL_ROWS))
  
  UUT (.i_Clk      (i_Clk),
       .i_HSync    (i_HSync),
       .i_VSync    (i_VSync),
       .o_HSync    (w_HSync),
       .o_VSync    (w_VSync),
       .o_Col_Count(w_Col_Count),
       .o_Row_Count(w_Row_Count)
      );
	  
  
  // Register syncs to align with output data.
  // OK.... So we set our outputs equal to the output from 
  //Sync_To_Count... not sure what good that does other than
  //maybe in the testbench we can see some results
  always @(posedge i_Clk)
  begin
     
    o_VSync <= w_VSync;
    o_HSync <= w_HSync;
    //for(i = 0; i < 16; i = i+1) begin
     // $display("mem2[%0d] = 0x%0h", i, Pattern_Red[i]);
    //end
  end
  

  
  // Pattern 7: Pong Video Game
  //remember what Russel said....
  //the reason we have to put 0 for when we are not setting it white is not only to make the color black
  //but also to make sure we don't run any high signals in the inactive area 
  //that would break our vga transmission
    
  assign Pattern_Red[0] = 
    (((c_LEFT_PONG_PADDLE_LEFT_SIDE - 1) <= w_Col_Count && w_Col_Count <= (c_LEFT_PONG_PADDLE_RIGHT_SIDE - 1) )  && ( (w_Row_Count - 5 >= r_Height_Left_Paddle) && w_Row_Count - 5 <= (r_Height_Left_Paddle + c_PONG_PADDLE_HEIGHT)))                   
    ||  (((c_RIGHT_PONG_PADDLE_LEFT_SIDE - 1) <= w_Col_Count && w_Col_Count <= (c_RIGHT_PONG_PADDLE_RIGHT_SIDE - 1) )  && ( (w_Row_Count - 5 >= r_Height_Right_Paddle) && w_Row_Count - 5 <= (r_Height_Right_Paddle + c_PONG_PADDLE_HEIGHT)))
    	|| (
          (w_Col_Count == r_Ball_X_Coord && w_Row_Count == r_Ball_Y_Coord) 
        || (w_Col_Count == r_Ball_X_Coord - 1 && w_Row_Count == r_Ball_Y_Coord) 
        || (w_Col_Count == r_Ball_X_Coord + 1 && w_Row_Count == r_Ball_Y_Coord) 
        || (w_Col_Count == r_Ball_X_Coord && w_Row_Count == r_Ball_Y_Coord - 1)
        || (w_Col_Count == r_Ball_X_Coord && w_Row_Count == r_Ball_Y_Coord + 1) 
        || (w_Col_Count == r_Ball_X_Coord - 1 && w_Row_Count == r_Ball_Y_Coord + 1) 
        || (w_Col_Count == r_Ball_X_Coord + 1 && w_Row_Count == r_Ball_Y_Coord + 1) 
        || (w_Col_Count == r_Ball_X_Coord - 1 && w_Row_Count == r_Ball_Y_Coord - 1)
        || (w_Col_Count == r_Ball_X_Coord + 1 && w_Row_Count == r_Ball_Y_Coord - 1) 
        || (r_Tally_Player_One >= 1 && w_Col_Count >= c_PLAYER_1_X_COORD_FIRST_TALLY && w_Col_Count <= (c_PLAYER_1_X_COORD_FIRST_TALLY + c_TALLY_MARK_WIDTH)  && c_TALLY_MARK_TOP_Y_COORD <= w_Row_Count && w_Row_Count <= c_TALLY_MARK_BOTTOM_Y_COORD)  
        || (r_Tally_Player_One >= 2 && w_Col_Count >= (1*c_INCREMENT_TALLY_MARK) + c_PLAYER_1_X_COORD_FIRST_TALLY && w_Col_Count <= (1*c_INCREMENT_TALLY_MARK) + (c_PLAYER_1_X_COORD_FIRST_TALLY + c_TALLY_MARK_WIDTH)  && c_TALLY_MARK_TOP_Y_COORD <= w_Row_Count && w_Row_Count <= c_TALLY_MARK_BOTTOM_Y_COORD)   
        || (r_Tally_Player_One >= 3 && w_Col_Count >= (2*c_INCREMENT_TALLY_MARK) + c_PLAYER_1_X_COORD_FIRST_TALLY && w_Col_Count <= (2*c_INCREMENT_TALLY_MARK) + (c_PLAYER_1_X_COORD_FIRST_TALLY + c_TALLY_MARK_WIDTH)  && c_TALLY_MARK_TOP_Y_COORD <= w_Row_Count && w_Row_Count <= c_TALLY_MARK_BOTTOM_Y_COORD)   
        || (r_Tally_Player_One >= 4 && w_Col_Count >= (3*c_INCREMENT_TALLY_MARK) + c_PLAYER_1_X_COORD_FIRST_TALLY && w_Col_Count <= (3*c_INCREMENT_TALLY_MARK) + (c_PLAYER_1_X_COORD_FIRST_TALLY + c_TALLY_MARK_WIDTH)  && c_TALLY_MARK_TOP_Y_COORD <= w_Row_Count && w_Row_Count <= c_TALLY_MARK_BOTTOM_Y_COORD)
        || (r_Tally_Player_Two >= 1 && w_Col_Count >= c_PLAYER_2_X_COORD_FIRST_TALLY && w_Col_Count <= (c_PLAYER_2_X_COORD_FIRST_TALLY + c_TALLY_MARK_WIDTH)  && c_TALLY_MARK_TOP_Y_COORD <= w_Row_Count && w_Row_Count <= c_TALLY_MARK_BOTTOM_Y_COORD)  
        || (r_Tally_Player_Two >= 2 && w_Col_Count >= (1*c_INCREMENT_TALLY_MARK) + c_PLAYER_2_X_COORD_FIRST_TALLY && w_Col_Count <= (1*c_INCREMENT_TALLY_MARK) + (c_PLAYER_2_X_COORD_FIRST_TALLY + c_TALLY_MARK_WIDTH)  && c_TALLY_MARK_TOP_Y_COORD <= w_Row_Count && w_Row_Count <= c_TALLY_MARK_BOTTOM_Y_COORD)   
        || (r_Tally_Player_Two >= 3 && w_Col_Count >= (2*c_INCREMENT_TALLY_MARK) + c_PLAYER_2_X_COORD_FIRST_TALLY && w_Col_Count <= (2*c_INCREMENT_TALLY_MARK) + (c_PLAYER_2_X_COORD_FIRST_TALLY + c_TALLY_MARK_WIDTH)  && c_TALLY_MARK_TOP_Y_COORD <= w_Row_Count && w_Row_Count <= c_TALLY_MARK_BOTTOM_Y_COORD)   
        || (r_Tally_Player_Two >= 4 && w_Col_Count >= (3*c_INCREMENT_TALLY_MARK) + c_PLAYER_2_X_COORD_FIRST_TALLY && w_Col_Count <= (3*c_INCREMENT_TALLY_MARK) + (c_PLAYER_2_X_COORD_FIRST_TALLY + c_TALLY_MARK_WIDTH)  && c_TALLY_MARK_TOP_Y_COORD <= w_Row_Count && w_Row_Count <= c_TALLY_MARK_BOTTOM_Y_COORD)     
           )

  
    
   ?
                          {VIDEO_WIDTH{1'b1}} : 0;
  assign Pattern_Grn[0] = Pattern_Red[0];
  assign Pattern_Blu[0] = Pattern_Red[0];
  

  /////////////////////////////////////////////////////////////////////////////
  // Select between different test patterns
  // so what's good to note is the assignment to an index[x] in the above
  // statements happens on a consistent basis which is why things like the 
  //checkerboard work since the program is constantly assigning these values
  //and these values (for instance the rows and column counts being the main
  //deciders) change every clock cycle which is why this output works below
  //based on the pattern chosen we feed a different output bit
  /////////////////////////////////////////////////////////////////////////////
  always @(posedge i_Clk)
  begin
    if(r_Game_Started == 1)
      begin
        o_Red_Video <= Pattern_Red[0];
        o_Grn_Video <= Pattern_Grn[0];
        o_Blu_Video <= Pattern_Blu[0];
        o_Game_Test <= r_Game_Test;
      end
  end
endmodule

