unit GameField;                      {gamefield.pp}

interface
uses MovPrintHero, Ratata;
const
    StartX = -200;
    StartY = -200;
    WorldWidth = 300;
    WorldHeight = 300;
    ObjectsCount = 1;

type
    FieldBlock = record
        ch: char;
        barrier: boolean;
        attend: boolean;
    end;

    GField = array [StartX..WorldWidth] of
        array [StartY..WorldHeight] of FieldBlock;


procedure GFieldInit(var field: Gfield);
procedure MoveHero(var h: hero; var r: ArrayRats; var field: Gfield; x, y: integer; ShiftX, ShiftY: integer);
procedure RewriteField(var field: Gfield; var h: Hero; var r: ArrayRats; ShiftX, ShiftY: integer);
procedure MoveRat(var r: rat; var field: Gfield; x, y: integer) ;
implementation
uses crt;

procedure InitObject(var field: Gfield; FileName: string; x, y: integer; BarrierFlag: boolean);
var
    f: text;
    pos, str: integer;
    ch: char;
begin
    {$I-}
    assign(f, 'worldobjects/' + FileName);
    reset(f);
    if IOResult <> 0 then begin
        writeln('Could not open ' + FileName);
        halt(1)
    end;
    pos := 0;
    str := 0;
    while not Eof(f) do begin
        read(f, ch);
        if ch = #10 then begin
            pos := 0;
            str := str + 1;
            continue
        end;
        pos := pos + 1;
        if ch = ' ' then
            continue;
        field[x+pos, y+str].ch := ch;
        field[x+pos, y+str].attend := false;
        case BarrierFlag of
        true: field[x+pos, y+str].barrier := true;
        false: field[x+pos, y+str].barrier := false
        end
    end
end;

procedure InitComplexObject(var field: Gfield; FileName: string; x, y: integer);
var
    Xshift, Yshift: integer;
    ch: integer;
    bool: integer;
    f: text;
begin
    {$I-}
    assign(f, 'worldobjects/' + FileName);
    reset(f);
    if IOResult <> 0 then begin
        writeln('Could not open ' + FileName);
        halt(1)
    end;
    while not SeekEof(f) do begin
        read(f, Xshift);
        read(f, Yshift);
        read(f, ch);
        read(f, bool);
        field[x+Xshift, y+Yshift].ch := char(ch);
        field[x+Xshift, y+Yshift].attend := false;
        case bool of
        0: field[x+Xshift, y+Yshift].barrier := false;
        1: field[x+Xshift, y+Yshift].barrier := true;
        end
    end
end;

procedure InitBorder(var field: Gfield);
var
    f: text;
    x, y: integer;
begin
    {$I-}
    assign(f, 'worldobjects/border.txt');
    reset(f);
    if IOResult <> 0 then begin
        writeln('Could not open border.txt');
        halt(1)
    end;
    while not SeekEof(f) do begin
        read(f, x);
        read(f, y);
        field[x, y].ch := '/';
        field[x, y].barrier:= true;
        field[x, y].attend:= false
    end
end;

procedure GFieldInit(var field: Gfield);
var
    x, y: integer;
begin
    for y := StartY to WorldHeight do
        for x := StartX to WorldWidth do begin
            field[x, y].ch := ' ';
            field[x, y].barrier := false;
            field[x, y].attend := false;

        end;

    InitObject(field, 'wallhome1.txt', -33, -6, true);
    InitObject(field, 'wallhome2.txt', 11, -6, true);
    InitObject(field, 'bed.txt', 5, 5, true);
    InitComplexObject(field, 'lantern.txt', 21, 0);
    InitComplexObject(field, 'lantern.txt', -7, 2);
    InitComplexObject(field, 'lantern.txt', 25, -10);
    InitComplexObject(field, 'lantern.txt', 52, -18);
    InitComplexObject(field, 'lantern.txt', 92, -15);
    InitComplexObject(field, 'lantern.txt', 88, -35);
    InitComplexObject(field, 'lantern.txt', 23, -39);
    InitObject(field, 'borderworld.txt', 188, -27, true);
    InitObject(field, 'water.txt', 112, -30, true);
    InitObject(field, 'bridge.txt', 112, -22, false);

    InitBorder(field)
end;

procedure RewriteField(var field: Gfield; var h: Hero; var r: ArrayRats; ShiftX, ShiftY: integer);
var
    x, y: integer;
begin
    for y := 1 to ScreenHeight do
        for x := 1 to ScreenWidth do begin 
            GotoXY(x, y);
            write(field[h.x + ShiftX + x, h.y + ShiftY + y].ch)
        end;
    ShowHero(h);
    ShowRats(r, h)
end;

function IsBarrierUnit (block: FieldBlock): boolean;
begin
    IsBarrierUnit := (block.ch <> ' ') and (block.barrier = true)
end;

function CheckBarrierX(var h: hero; var field: Gfield; ShiftX: integer): boolean;
var
    y: integer;
begin
    for y := (h.y - 1) to (h.y + 2) do
        if IsBarrierUnit(field[h.x + ShiftX, y]) then begin
            CheckBarrierX := true;
            exit
        end;
    CheckBarrierX := false;
end;


function CheckBarrierY(var h: hero; var field: Gfield; ShiftY: integer): boolean;
var
    x: integer;
begin
    for x := (h.x - 3) to (h.x + 1) do
        if IsBarrierUnit(field[x, h.y+ShiftY]) then begin
            CheckBarrierY := true;
            exit
        end;
    CheckBarrierY := false;
end;

function IsBarrier(var h: hero; var field: Gfield; x, y: integer): boolean;
begin
    case x of
    -1: begin
        IsBarrier := CheckBarrierX(h, field, LeftHeroBorder); 
        exit
    end;
    1: begin
        IsBarrier := CheckBarrierX(h, field, RightHeroBorder);
        exit
    end
    end;
    case y of
    -1: begin
        IsBarrier := CheckBarrierY(h, field, UpHeroBorder); 
        exit
    end;
    1: begin
        IsBarrier := CheckBarrierY(h, field, DownHeroBorder);
        exit
    end
    end
end;

procedure MoveHero(var h: hero; var r: ArrayRats; var field: Gfield; x, y: integer; ShiftX, ShiftY: integer);
begin
    if not IsBarrier(h, field, x, y) then begin
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
        // RewriteField(field, h, r, ShiftX, ShiftY);
   end
end;

procedure MoveRat(var r: rat; var field: Gfield; x, y: integer) ;
begin
    r.x := r.x + x;
    r.y := r.y + y; 
    if x = -1 then
        r.Duration := RatPrintLeft
    else if x = 1 then
        r.Duration := RatPrintRight
end;

end.
