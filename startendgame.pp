unit StartEndGame;             {startendgame.pp}

interface
procedure ToEndGame;
procedure ToStartGame;
procedure GameOver;

implementation
uses crt, MovPrintChar;

const
    {copy the first string to the Logo picture, instead of to count length}
    StringLength = length('  /###           /   /                                                         ');
    PicY = 4;                               {start string to the pixture}
    MenuY = 25;                             {start string to the menu}
    MenuShift = -32;                        {x-axis offset for menu item}
    SwitchCount = 2;                        {count of menu item}
    DefaultEsc = #27'[0m';                  {esc-seq default settings}
    GaOv = 'Game Over';
type
    actions = (StartGame, ExitGame);        {enable menu items}

    SwitchPoint = record                    {type for one menu item}
        action: actions;
        x, y: integer;                      {coordinate}
        name: string[15];                   {prining name}
    end;

    SwitchArray = array[1..SwitchCount] of SwitchPoint;

var
    switch: SwitchArray;
    PrintStartImg: array[1..18] of string[StringLength] = (
'  /###           /   /                                                         ',
' /  ############/  #/                                                          ',
'/     #########    ##                    ##     ####  #####  ####  ##  #  ###  ',
'#     /  #         ##                    ##     ##    ##     ##    ### #  ##  #',
' ##  /  ##         ##                    ##     ####  ## ##  ####  # ###  ##  #',
'    /  ###         ##  /##      /##      ##     ##    ##  #  ##    #  ##  ##  #',
'   ##   ##         ## / ###    / ###     #####  ####  #####  ####  #   #  ###  ',
'   ##   ##         ##/   ###  /   ###                                          ',
'   ##   ##         ##     ## ##    ###                OF THE SUN               ',
'   ##   ##         ##     ## ########                                          ',
'    ##  ##         ##     ## #######                                           ',
'     ## #      /   ##     ## ##                                                ',
'      ###     /    ##     ## ####    /                                         ',
'       ######/     ##     ##  ######/                                          ',
'         ###        ##    ##   #####                                           ',
'                          /                                                    ',
'                         /                              ###################### ',
'                        /          ########################################### '
);

procedure SwitchInit;
{Initialization of the Menu array}
begin
    switch[1].action := StartGame;
    switch[1].x := (ScreenWidth + MenuShift) div 2;
    switch[1].y := MenuY; 
    switch[1].name := 'start game'; 

    switch[2].action := StartGame;
    switch[2].x := (ScreenWidth + MenuShift) div 2;
    switch[2].y := MenuY + 2; 
    switch[2].name := 'exit' 
end;

procedure ToEndGame;
begin
    clrscr;
    write(DefaultEsc);            {esc-sequence for defaultsettings}
    halt
end;

procedure GameOver;
begin
    clrscr;
    GotoXY((ScreenWidth - length(GaOV)) div 2, ScreenHeight div 2);
    write(GaOv);
    GotoXY(1, 1);
    delay(3000);
    ToEndGame
end;

{procedure RedrawAsterisk;}

procedure ToStartGame;
var
    i: integer;
    y: integer = PicY;
    c: SmallInt;
begin
    SwitchInit;
    clrscr;
    {draw the logo}
    for i := 1 to length(PrintStartImg) do begin
        GotoXY((ScreenWidth - StringLength) div 2, y);
        writeln(PrintStartImg[i]);
        y := y + 1;
    end;
    {draw the menu item's names}
    for i := 1 to SwitchCount do begin
        GotoXY(switch[i].x, switch[i].y);
        writeln(switch[i].name);
    end;
    {draw the select asterisk in the start position}
    i := 1;
    ShowChar('*', switch[i].x - 2, switch[i].y);
    GotoXY(1, 1);
    {cycle of menu items}
    while true do begin
        GetKey(c);
        case c of
        -72: begin 
            ShowChar(' ', switch[i].x - 2, switch[i].y);
            if i > 1 then
                i := i - 1;
            ShowChar('*', switch[i].x - 2, switch[i].y);
            GotoXY(1, 1)
        end;
        -80: begin
            ShowChar(' ', switch[i].x - 2, switch[i].y);
            if i < 2 then
                i := i + 1;
            ShowChar('*', switch[i].x - 2, switch[i].y);
            GotoXY(1, 1)
        end;
        13: begin
            case i of
            1: exit;
            2: ToEndGame;
            end
            end
        end
    end
end;

end.
