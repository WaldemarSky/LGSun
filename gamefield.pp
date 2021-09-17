unit GameField;                      {gamefield.pp}

interface
uses crt, MovPrintHero;
const
    StartX = -200;
    StartY = -200;
    WorldWidth = 300;
    WorldHeight = 300;

type
    GField = array [StartY..WorldHeight] of
        array [StartX..WorldWidth] of char;

procedure GFieldInit(var field: Gfield);
procedure RewriteField(field: Gfield; h: Hero; ShiftX, ShiftY: integer);
implementation


procedure GFieldInit(var field: Gfield);
var
    x, y: integer;
begin
    for y := StartY to WorldHeight do
        for x := StartX to WorldWidth do
            field[x, y] := ' ';
    // InitObgects(field);
    field[-7, -7] := 'm';
    field[-6, -7] := 'i';
    field[-5, -7] := 'r'
end;

procedure RewriteField(field: Gfield; h: Hero; ShiftX, ShiftY: integer);
var
    x, y: integer;
begin
    for y := 1 to ScreenHeight do
        for x := 1 to ScreenWidth do begin 
            GotoXY(x, y);
            write(field[h.x + ShiftX + x, h.y + ShiftY + y])
        end;
    ShowHero(h);
end;

end.
