unit GameField;                      {gamefield.pp}

interface
uses crt, MovPrintHero;
const
    StartX = -200;
    StartY = -200;
    WorldWidth = 300;
    WorldHeight = 300;

type
    FieldBlock = record
        ch: char;
        barrier: boolean;
    end;

    GField = array [StartY..WorldHeight] of
        array [StartX..WorldWidth] of FieldBlock;

procedure GFieldInit(var field: Gfield);
procedure MoveHero(var h: hero; var field: Gfield; x, y: integer; ShiftX, ShiftY: integer);
procedure RewriteField(field: Gfield; h: Hero; ShiftX, ShiftY: integer);
implementation


procedure GFieldInit(var field: Gfield);
var
    x, y: integer;
begin
    for y := StartY to WorldHeight do
        for x := StartX to WorldWidth do begin
            field[x, y].ch := ' ';
            field[x, y].barrier := false;
        end;
    // InitObgects(field);
    field[-7, -7].ch := 'm'; field[-7, -7].barrier := true;
    field[-6, -7].ch := 'i'; field[-6, -7].barrier := true;
    field[-5, -7].ch := 'r'; field[-5, -7].barrier := true;

    field[7, -7].ch := 'f'; field[7, -7].barrier := false;
    field[8, -7].ch := 'l'; field[8, -7].barrier := false;
    field[9, -7].ch := 'r'; field[9, -7].barrier := false;
end;

procedure RewriteField(field: Gfield; h: Hero; ShiftX, ShiftY: integer);
var
    x, y: integer;
begin
    for y := 1 to ScreenHeight do
        for x := 1 to ScreenWidth do begin 
            GotoXY(x, y);
            write(field[h.x + ShiftX + x, h.y + ShiftY + y].ch)
        end;
    ShowHero(h);
end;

procedure MoveHero(var h: hero; var field: Gfield; x, y: integer; ShiftX, ShiftY: integer);
begin
    // if not IsBarrier then begin
        h.x := h.x + x;
        h.y := h.y + y;
        case x of
        -1: h.duration := HdLeft;
        1: h.duration := HdRight;
        end;
        case y of
        -1: h.duration := HdUp;
        1: h.duration := HdDown;
        end;
        if ((y = -1) or (x = -1)) and (ord(h.condition) > 2) then
            h.condition := HcBackFirst
        else if ((y = 1) or (x = 1)) and (ord(h.condition) < 3) then
            h.condition := HcFrontFirst
        else if ord(h.condition) mod 3 = 0 then
            h.condition := succ(h.condition) 
        else
            h.condition := pred(h.condition);
        RewriteField(field, h, ShiftX, ShiftY);
   // end
end;


end.
