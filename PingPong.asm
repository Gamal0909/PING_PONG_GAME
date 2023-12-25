.MODEL LARGE
.DATA
   ;MAIN MENU
   WELCOME_MSG DB "            WELCOME TO OUR GAME",'$'
   START_MSG DB "1) START",'$'
   QUIT_MSG DB "2) QUIT",'$'
   CHOOSE_MSG DB "CHOOSE 1 OR 2",'$'
    ; WINNER MSG
    GAME_OVER_MSG DB "            GAME OVER",'$'
    PLAYER_ONE_WIN DB "PLAYER_ONE_WIN",'$'
    PLAYER_TWO_WIN DB "PLAYER_TWO_WIN",'$'
    
    ;for new line
    n_line DB 0AH,0DH,"$"
    
    ;SCORE MSG
    PLAYER_ONE_MSG DB "   PLAYER_1: ",'$'
    PLAYER_TWO_MSG DB "   PLAYER_2: ",'$' 
    
    ;WINDOW SIZE
    WIN_W DW 140H
    WIN_H DW 0C8H
    WIN_BOUND DW 6
    
    TIME_AUX DB 0 ;TIME 
    
    ;BALL ORG POS
    BALL_ORG_X DW 0A0H
     BALL_ORG_Y DW 64H

    ;BALL POSTION
     BALL_X DW 0A0h   ;X POS
     BALL_Y DW 064H   ;Y POS

    
    ;BALL SIZE
    BALL_SIZE DW 04H
    
    ;SPEED
    BALL_SPEED_X DW 05H
    BALL_SPEED_Y DW 02H
    
    
    
    ;LEFT PADDLE POS
    PADDLE_LEFT_X DW 0AH
    PADDLE_LEFT_Y DW 0AH
    
    
    ;RIGHT PADDLE POS
    PADDLE_RIGHT_X DW 135H
    PADDLE_RIGHT_Y DW 0AH
    
    
    ;PADDLE SIZE
    PADDLE_W DW 05H
    PADDLE_H DW 1FH
    
    ;PADDLE SPEED
     PADDLE_SPEED DW 05H
     
     
    ;ORG SCOOR PLAYER
    ORG_PALYER_ONE_SCORE DB 00;
    ORG_PALYER_TWO_SCORE DB 00;
    
    
    ;SCOOR PLAYER
    PALYER_ONE_SCORE DB 00;
    PALYER_TWO_SCORE DB 00;
.STACK
.CODE
    MAIN PROC FAR
        .STARTUP
     L1:
        MOV AL,02H
        MOV AH,00H
        INT  10H
        CALL MAIN_MENU
        MOV AH,01H
        INT 21H
        SUB AL ,30H
        CMP AL,1H
        JE L2
        JNE L3
      L3:
         CMP AL,2H
         JE L4
         JNE L1
      L2:
        
         CALL GAME
      L4:
         CALL EXIT
        
     MAIN ENDP
    
    
     EXIT PROC NEAR
     
        MOV AH,4CH
        INT 21H
     EXIT ENDP
    
    ;MENU FUN
     MAIN_MENU PROC NEAR
        CALL CLEAR_SCREEN
        
        LEA DX,WELCOME_MSG;WELCOME MSG
        MOV AH,09
        INT 21H
        
        CALL NEW_LINE
        
        LEA DX,CHOOSE_MSG
        MOV AH,09H
        INT 21H
        
        CALL NEW_LINE
        
        LEA DX,START_MSG;START MSG
        MOV AH,09
        INT 21H
        
        CALL NEW_LINE
        
        LEA DX,QUIT_MSG;QUIT MSG
        MOV AH,09H
        INT 21H 
        
        CALL NEW_LINE    
        
        RET
    MAIN_MENU ENDP
             
             
             
             
     ;GAME FUN
     
    GAME PROC NEAR
        CALL CLEAR_SCREEN                
        
    CHK_TIME:
        MOV AH,2CH
        INT 21H
        CMP DL,TIME_AUX
        JE CHK_TIME
        MOV TIME_AUX,DL
        
        
        
        CALL CLEAR_SCREEN
        CALL MOVE_BALL
        CALL MOVE_PADDLE 
        CALL PRINT_SCORE
        CALL DROW_BALL
        CALL DROW_PADDLES
        
        
        JMP CHK_TIME
        
        RET    
    GAME ENDP 
    
    
    
    
    MOVE_BALL PROC NEAR
        
        ;MOVE BALL IN X
        MOV DX,BALL_SPEED_X
        ADD BALL_X,DX
        
        ; CHK IF BALL OUT WINDOW IN X
        MOV AX,WIN_BOUND
        CMP BALL_X,AX
        JL  POINT_TO_PLAYER_TWO
        
        
        MOV DX,WIN_W
        SUB DX,BALL_SIZE
        SUB DX,WIN_BOUND
        CMP BALL_X ,DX
        JG POINT_TO_PLAYER_ONE
        JMP MOVE_BALL_Y
   POINT_TO_PLAYER_TWO:
        MOV AL,PALYER_TWO_SCORE
        INC AL
        MOV PALYER_TWO_SCORE ,AL
        CMP AL,09H
        JE GAMEOVER
        CALL RESET_POSITION
        RET
    POINT_TO_PLAYER_ONE:
        MOV AL,PALYER_ONE_SCORE
        INC AL
        MOV PALYER_ONE_SCORE ,AL
        CMP AL,09H
        JE GAMEOVER
        CALL RESET_POSITION
        RET
    GAMEOVER:
        CALL GAME_OVER
        RET
    MOVE_BALL_Y:
        ;MOVE BALL IN Y
        MOV DX,BALL_SPEED_Y
        ADD BALL_Y,DX
        
        ; CHK IF BALL OUT WINDOW IN Y
        MOV AX,WIN_BOUND
        CMP BALL_Y,AX
        JL NEG_Y
        
        
        MOV DX,WIN_H
        SUB DX,BALL_SIZE
        SUB DX,WIN_BOUND
        CMP BALL_Y,DX
        JG NEG_Y
        JMP CHK_CRASH_RIGHT_PADDLE
     NEG_Y:
        NEG BALL_SPEED_Y
        RET 
        
        
        ;CHK IF BALL CRASH IN RIGHT PADDLE
    CHK_CRASH_RIGHT_PADDLE:
        MOV AX,BALL_X
        ADD AX,BALL_SIZE
        CMP AX,PADDLE_RIGHT_X
        JNG CHK_CRASH_LEFT_PADDLE
       
       
        MOV AX,PADDLE_RIGHT_X
        ADD AX,PADDLE_W
        CMP BALL_X,AX
        JNL CHK_CRASH_LEFT_PADDLE
         
        
        
        MOV AX,BALL_Y
        ADD AX,BALL_SIZE
        CMP AX,PADDLE_RIGHT_Y
        JNG CHK_CRASH_LEFT_PADDLE
       
       
        MOV AX,PADDLE_RIGHT_Y
        ADD AX,PADDLE_H
        CMP BALL_Y,AX
        JNL CHK_CRASH_LEFT_PADDLE
        
        
        JMP NEG_X
        ;CHK IF BALL CRASH IN LEFT PADDLE
    CHK_CRASH_LEFT_PADDLE:
        
        MOV AX,BALL_X
        ADD AX,BALL_SIZE
        CMP AX,PADDLE_LEFT_X
        JNG RT
       
       
        MOV AX,PADDLE_LEFT_X
        ADD AX,PADDLE_W
        CMP BALL_X,AX
        JNL RT
         
        
        
        MOV AX,BALL_Y
        ADD AX,BALL_SIZE
        CMP AX,PADDLE_LEFT_Y
        JNG RT
       
       
        MOV AX,PADDLE_LEFT_Y
        ADD AX,PADDLE_H
        CMP BALL_Y,AX
        JNL RT
        JMP NEG_X
               
        
    NEG_X:
        NEG BALL_SPEED_X 
        RET
    RT: 
        RET
       
     MOVE_BALL ENDP
    ;RESET POS AFTER POINT
    RESET_POSITION PROC NEAR
        MOV DX,BALL_ORG_X
        MOV BALL_X,DX
    
        
        MOV DX,BALL_ORG_Y
        MOV BALL_Y,DX
        
        RET
    RESET_POSITION ENDP
    
    
    
    ;DROW BALL FUN
    DROW_BALL PROC NEAR
        MOV CX,BALL_X;(X)INITIAL_POSTION
        MOV DX,BALL_Y;(Y)INITIAL_POSTION
        
    
        HORIZONTAL:
            MOV AH,0CH  ;DROW PIXEL (BALL)
            MOV AL,0FH
            MOV BH,00H 
            INT 10H
            
            INC CX;CHANGE BALL SIZE FROM DEFULT 
            MOV AX,CX
            SUB AX,BALL_X
            CMP AX,BALL_SIZE
            JNG HORIZONTAL
            MOV CX,BALL_X
            INC DX
            MOV AX,DX
            SUB AX,BALL_Y
            CMP AX,BALL_SIZE
            JNG HORIZONTAL
            
        RET
    DROW_BALL ENDP
     
    ;CLEAR SCREEN FUN
    CLEAR_SCREEN PROC NEAR
    
    
        MOV AH,00H ;VIDEO MODE
        MOV AL,13H
        INT 10H
        
        MOV AH,0BH  ; backgroung colur
        MOV BH,00H
        MOV BL,00H    
        int 10H
        RET
    CLEAR_SCREEN ENDP
    
    ; PRINT SCORE FUN
    PRINT_SCORE PROC NEAR
           LEA DX,PLAYER_ONE_MSG
           MOV AH,09H
           INT 21H
           
           MOV DL,PALYER_ONE_SCORE
           ADD DL,30H
           MOV AH,02H
           INT 21H
          
          
          LEA DX,PLAYER_TWO_MSG
           MOV AH,09H
           INT 21H
           
           MOV DL,PALYER_TWO_SCORE
           ADD DL,30H
           MOV AH,02H
           INT 21H 
    PRINT_SCORE ENDP
    
     ;DROW PADDLE FUN
    DROW_PADDLES PROC NEAR
        ; DROW LEFT PADDLE
        MOV CX,PADDLE_LEFT_X
        MOV DX,PADDLE_LEFT_Y
    LEFT_PADDLE_HORIZONTAL:
        MOV AH,0CH  ;DROW PIXEL (PADDLE)
        MOV AL,0FH
        MOV BH,00H 
        INT 10H
        
        INC CX;CHANGE PADDLE SIZE
        MOV AX,CX
        SUB AX,PADDLE_LEFT_X
        CMP AX,PADDLE_W
        JNG LEFT_PADDLE_HORIZONTAL
        MOV CX,PADDLE_LEFT_X
        INC DX
        MOV AX,DX
        SUB AX,PADDLE_LEFT_Y
        CMP AX,PADDLE_H
        JNG LEFT_PADDLE_HORIZONTAL
                
            
            
            
        ; DROW RIGHT PADDLE
        MOV CX,PADDLE_RIGHT_X
        MOV DX,PADDLE_RIGHT_Y
    RIGHT_PADDLE_HORIZONTAL:
        MOV AH,0CH  ;DROW PIXEL (PADDLE)
        MOV AL,0FH
        MOV BH,00H 
        INT 10H
        
        INC CX;CHANGE PADDLE SIZE
        MOV AX,CX
        SUB AX,PADDLE_RIGHT_X
        CMP AX,PADDLE_W
        JNG RIGHT_PADDLE_HORIZONTAL
        MOV CX,PADDLE_RIGHT_X
        INC DX
        MOV AX,DX
        SUB AX,PADDLE_RIGHT_Y
        CMP AX,PADDLE_H
        JNG RIGHT_PADDLE_HORIZONTAL   
            
            RET
    DROW_PADDLES ENDP

    
    
    
    
    
    
    
    
    ;PADDLE MOVEMENT FUN
    MOVE_PADDLE PROC NEAR
        
        ;LEFT PADDLE
        ;chk if downkey
        MOV AH,01H;GET KEY STATUS
        INT 16H
        JZ CHK_RIGHT_PADDLE_MOVEMENT;JMP IF ZERO FLAGE =1
        
        ;chk which downkey
        MOV AH,00H
        INT 16H
        
        
        ;'W'||'w' move up
        CMP AL,77H
        JE MOVE_LEFT_PADDLE_UP
        CMP AL,57H
        JE MOVE_LEFT_PADDLE_UP
        ;'s'||'S' move DOWN
        CMP AL,73H
        JE MOVE_LEFT_PADDLE_DOWN
        CMP AL,53H
        JE MOVE_LEFT_PADDLE_DOWN
        JMP CHK_RIGHT_PADDLE_MOVEMENT
        
        
    MOVE_LEFT_PADDLE_UP:
        MOV DX,PADDLE_SPEED
        SUB PADDLE_LEFT_Y,DX
        MOV DX,WIN_BOUND
        CMP PADDLE_LEFT_Y,DX
        JL FIX_LEFT_TOP_POS
        JMP CHK_RIGHT_PADDLE_MOVEMENT
    FIX_LEFT_TOP_POS:
        MOV DX,WIN_BOUND
        MOV PADDLE_LEFT_Y,DX
        JMP CHK_RIGHT_PADDLE_MOVEMENT
        
    MOVE_LEFT_PADDLE_DOWN:
        MOV DX,PADDLE_SPEED
        ADD PADDLE_LEFT_Y,DX
        MOV AX,WIN_H
        SUB AX,WIN_BOUND
        SUB AX,PADDLE_H
        CMP PADDLE_LEFT_Y,AX
        JG FIX_LEFT_DOWN_POS
        JMP CHK_RIGHT_PADDLE_MOVEMENT
        
    FIX_LEFT_DOWN_POS:
        MOV PADDLE_LEFT_Y,AX
        JMP CHK_RIGHT_PADDLE_MOVEMENT
        
        
        
        
        
        ;RIGHT PADDLE
        ;chk if downkey
    CHK_RIGHT_PADDLE_MOVEMENT:
        
        
        
        ;'a'||'A' move up
        CMP AL,61H
        JE MOVE_RIGHT_PADDLE_UP
        CMP AL,41H
        JE MOVE_RIGHT_PADDLE_UP
        ;'D'||'d' move DOWN
        CMP AL,64H
        JE MOVE_RIGHT_PADDLE_DOWN
        CMP AL,44H
        JE MOVE_RIGHT_PADDLE_DOWN
        JMP EXIT_MOVE_PROC
        
        
    MOVE_RIGHT_PADDLE_UP:
        
        MOV DX,PADDLE_SPEED
        SUB PADDLE_RIGHT_Y,DX
        MOV DX,WIN_BOUND
        CMP PADDLE_RIGHT_Y,DX
        JL FIX_RIGHT_TOP_POS
        JMP EXIT_MOVE_PROC
    FIX_RIGHT_TOP_POS:
        MOV DX,WIN_BOUND
        MOV PADDLE_RIGHT_Y,DX
        JMP EXIT_MOVE_PROC
        
        
        
    MOVE_RIGHT_PADDLE_DOWN:
        MOV DX,PADDLE_SPEED
        ADD PADDLE_RIGHT_Y,DX
        MOV AX,WIN_H
        SUB AX,WIN_BOUND
        SUB AX,PADDLE_H
        CMP PADDLE_RIGHT_Y,AX
        JG FIX_RIGHT_DOWN_POS
        JMP EXIT_MOVE_PROC
        
    FIX_RIGHT_DOWN_POS:
        MOV PADDLE_RIGHT_Y,AX
        JMP EXIT_MOVE_PROC
        
        
    EXIT_MOVE_PROC:
        RET
        
        
    MOVE_PADDLE ENDP
    
    
    ;GAME OVER FUN
    GAME_OVER PROC NEAR
        CALL CLEAR_SCREEN
        
        LEA DX,GAME_OVER_MSG
        MOV AH,9H
        INT 21H
        
        CALL NEW_LINE
        
        MOV AL,PALYER_ONE_SCORE
        CMP AL,09H
        JE ONE_WINNER
        MOV AL,PALYER_TWO_SCORE
        CMP AL,09H
        JE TWO_WINNER
        
        
        
        
    ONE_WINNER:
       LEA DX,PLAYER_ONE_WIN
       MOV AH,09H
        INT 21H
        
        CALL NEW_LINE
        JMP EN
        
        
        
    TWO_WINNER: 
        LEA DX,PLAYER_TWO_WIN
        MOV AH,9H
        INT 21H
    EN:
        MOV AL,ORG_PALYER_ONE_SCORE
        MOV PALYER_ONE_SCORE,AL
    
    
        MOV AL,ORG_PALYER_TWO_SCORE
        MOV PALYER_TWO_SCORE,AL
        
        LEA DX,CHOOSE_MSG
        MOV AH,09H
        INT 21H
        
        CALL NEW_LINE
        
        LEA DX,START_MSG;START MSG
        MOV AH,09
        INT 21H
        
        CALL NEW_LINE
        
        LEA DX,QUIT_MSG;QUIT MSG
        MOV AH,09H
        INT 21H 
        
        CALL NEW_LINE    
        
        
        
        MOV AH,10H
        INT 16H
        SUB AL,30H
        CMP AL,1H
        JE M
        CMP AL,2H
        JE EX
        JNE EN
    EX:
        CALL EXIT
    M:
        CALL GAME
        RET
    GAME_OVER ENDP
    
    NEW_LINE PROC NEAR
    
        LEA DX,n_line 
        MOV AH,9H
        INT 21H
        RET
    NEW_LINE ENDP
END MAIN       
