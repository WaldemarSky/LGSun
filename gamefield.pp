unit GameField;                      {gamefield.pp}

interface
uses MovPrintHero, Ratata, TaskStackUnit;
const
    StartX = -200;
    StartY = -200;
    WorldWidth = 300;
    WorldHeight = 300;
    ObjectsCount = 1;
    HeroSN = 1;
    RatSN = 2;

type
    FieldBlock = record
        ch: char;
        barrier: boolean;
        attend: byte;
    end;

    GField = array [StartX..WorldWidth] of
        array [StartY..WorldHeight] of FieldBlock;

procedure GFieldInit(var field: Gfield);
procedure InitRatAttend(var r: rat; var field: Gfield; attend: byte);
procedure InitHeroAttend(var h: hero; var field: Gfield; attend: byte);
procedure MoveHero(var h: hero; var r: ArrayRats; var field: Gfield; x, y: integer; ShiftX, ShiftY: integer);
procedure RewriteField(var field: Gfield; var h: Hero; var r: ArrayRats; ShiftX, ShiftY: integer);
procedure RewriteAreaField(var field: Gfield; var h: hero; StartX, StartY, EndX, EndY: integer);
procedure MoveRat(var r: rat; var h: hero; var field: Gfield; x, y: integer);
procedure HitHero(var h: Hero; var field: Gfield; var r: ArrayRats; ShiftX, ShiftY: integer);
procedure EndHitHero(var h: Hero; var field: Gfield; var stack: TaskStack; var r: ArrayRats; ShiftX, ShiftY: integer);

implementation
uses crt, SysUtils, DateUtils;

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
        field[x+pos, y+str].attend := 0;
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
        field[x+Xshift, y+Yshift].attend := 0;
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
        field[x, y].barrier := true;
        field[x, y].attend := 0;
    end
end;

procedure InitRatAttend(var r: rat; var field: Gfield; attend: byte);
var
    i: integer;
begin
    for i := 0 to 3 do
        field[r.x + i, r.y].attend := attend 
end;

procedure GFieldInit(var field: Gfield);
var
    x, y: integer;
begin
    for y := StartY to WorldHeight do
        for x := StartX to WorldWidth do begin
            field[x, y].ch := ' ';
            field[x, y].barrier := false;
            field[x, y].attend := 0;
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
    for y := 2 to (ScreenHeight div 2 - 2) do
        for x := 1 to ScreenWidth do begin 
            GotoXY(x, y);
            write(field[h.x + ShiftX + x, h.y + ShiftY + y].ch)
        end;

    for y := (ScreenHeight div 2 - 1) to (ScreenHeight div 2 + 1) do begin
        for x := 1 to ScreenWidth div 2 - 4 do begin 
            GotoXY(x, y);
            write(field[h.x + ShiftX + x, h.y + ShiftY + y].ch)
        end;
        for x := (ScreenWidth div 2 + 2) to ScreenWidth do begin 
            GotoXY(x, y);
            write(field[h.x + ShiftX + x, h.y + ShiftY + y].ch)
        end
    end;

    y := ScreenHeight div 2 + 2;
    for x := 1 to ScreenWidth div 2 - 3 do begin 
        GotoXY(x, y);
        write(field[h.x + ShiftX + x, h.y + ShiftY + y].ch)
    end;
    for x := (ScreenWidth div 2 + 1) to ScreenWidth do begin 
        GotoXY(x, y);
        write(field[h.x + ShiftX + x, h.y + ShiftY + y].ch)
    end;

    for y := (ScreenHeight div 2 + 3) to ScreenHeight-1 do
        for x := 1 to ScreenWidth do begin 
            GotoXY(x, y);
            write(field[h.x + ShiftX + x, h.y + ShiftY + y].ch)
        end;
    ShowHero(h);
    ShowRats(r, h);
    WriteStatusBar(h);
end;

function IsInsideVision(x, y: integer): boolean;
begin
    IsInsideVision := (x > 0) and (x <= ScreenWidth) and
        (y > 1) and (y < ScreenHeight)
end;

procedure RewriteAreaField(var field: Gfield; var h: hero; StartX, StartY, EndX, EndY: integer);
var
    x, y: integer;
begin
    for y := StartY to EndY do
        for x := StartX to EndX do begin
            if IsInsideVision(x - h.x + h.CenXfield, y - h.y + h.CenY) then begin
                GotoXY(x - h.x + h.CenXfield, y - h.y + h.CenY);
                write(field[x, y].ch);
            end
        end;
    GotoXY(1, 1)
end;

function IsBarrierUnit (block: FieldBlock): boolean;
begin
    IsBarrierUnit := (block.attend <> 0) or (block.barrier = true)
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

procedure InitHeroAttend(var h: hero; var field: Gfield; attend: byte);
var
    x, y: integer;
begin
    for y := (h.y - 1) to (h.y + 2) do
        for x := (h.x + LeftHeroBorder + 1) to (h.x + RightHeroBorder - 1) do begin
            field[x, y].attend := attend;
        end
end;

procedure MoveHero(var h: hero; var r: ArrayRats; var field: Gfield; x, y: integer; ShiftX, ShiftY: integer);
begin
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
    else if ((y = 1) or (x = 1)) and (ord(h.condition) < 3) then begin
        h.condition := HcFrontFirst;
        h.BlinkTimer := now
    end
    else if ord(h.condition) mod 3 = 0 then
        h.condition := succ(h.condition) 
    else
        h.condition := pred(h.condition);
    if not IsBarrier(h, field, x, y) then begin
        InitHeroAttend(h, field, 0);
        h.x := h.x + x;
        h.y := h.y + y;
        InitHeroAttend(h, field, HeroSN);
    end;
    RewriteField(field, h, r, ShiftX, ShiftY)
end;

function CheckRatBarrierX(var r: rat; field: Gfield; ShiftX: integer): boolean;
begin
    if IsBarrierUnit(field[r.x + ShiftX, r.y]) then
        CheckRatBarrierX := true
    else
        CheckRatBarrierX := false
end;

function CheckRatBarrierY(var r: rat; field: Gfield; ShiftY: integer): boolean;
var
    x: integer;
begin
    for x := r.x to r.x + 3 do
    if IsBarrierUnit(field[x, r.y + ShiftY]) then begin
        CheckRatBarrierY := true;
        exit
    end;
    CheckRatBarrierY := false;
end;

function isRatBarrier(var r: rat; var field: Gfield; x, y: integer): boolean;
begin
    case x of
    -1: begin
        IsRatBarrier := CheckRatBarrierX(r, field, -1); 
        exit
    end;
    1: begin
        IsRatBarrier := CheckRatBarrierX(r, field,  4);
        exit
    end
    end;
    case y of
    -1: begin
        IsRatBarrier := CheckRatBarrierY(r, field, -1); 
        exit
    end;
    1: begin
        IsRatBarrier := CheckRatBarrierY(r, field, 1);
        exit
    end
    end
end;

procedure HideRat(var r: rat; var h: hero; var field: Gfield);
var
    x, y: integer;
    i: integer;
begin
    InitRatAttend(r, field, 0);
    x := h.CenXField + r.x - h.x;
    y := h.CenY + r.y - h.y;
    if IsInsideVision(x, y) then
        for i := 0 to 3 do begin
            GotoXY(x + i, y);
            write(field[r.x + i, r.y].ch)
        end
end;

procedure MoveRat(var r: rat; var h: hero; var field: Gfield; x, y: integer);
begin
    if not isRatBarrier(r, field, x, y) then begin
        HideRat(r, h, field);
        r.x := r.x + x;
        r.y := r.y + y; 
        if x = -1 then
            r.Duration := RatPrintLeft
        else if x = 1 then
            r.Duration := RatPrintRight;
        InitRatAttend(r, field, RatSN);
        ShowRat(r, h);
        GotoXY(1, 1)
    end
end;


procedure RewritePartField(var field: Gfield; var h: Hero; var r: ArrayRats; ShiftX, ShiftY: integer);
var
    x, y: integer;
begin
    for y := (ScreenHeight div 2 - 1) to (ScreenHeight div 2 + 2) do begin
        for x := (ScreenWidth div 2 - 6) to (ScreenWidth div 2 - 4) do begin 
            GotoXY(x, y);
            write(field[h.x + ShiftX + x, h.y + ShiftY + y].ch)
        end;
        for x := (ScreenWidth div 2 + 2) to (ScreenWidth div 2 + 4) do begin 
            GotoXY(x, y);
            write(field[h.x + ShiftX + x, h.y + ShiftY + y].ch)
        end
    end;
    ShowHero(h);
    ShowRats(r, h);
    GotoXY(1, 1)
end;

function CheckDuration(var h: hero; var r:ArrayRats): integer;
var
    x, y: integer;
    i: integer;
begin
    case h.duration of
    HdLeft: begin
        for y:= h.y to h.y + 2 do begin
            for x := (h.x - 9) to (h.x - 7) do begin
                for i := 1 to RatCount do
                    if (r[i].x = x) and (r[i].y = y) then begin
                        CheckDuration := i;
                        exit
                    end
            end
        end
    end;
    HdRight: begin
        for y:= h.y to h.y + 2 do begin
            for x := (h.x + 2) to (h.x + 4) do begin
                for i := 1 to RatCount do
                    if (r[i].x = x) and (r[i].y = y) then begin
                        CheckDuration := i;
                        exit
                    end
            end
        end
    end
    end;
    CheckDuration := 0
end;

procedure ToKill(var h: hero; var r: ArrayRats; var field: Gfield);
var
    who: integer;
begin
    who := CheckDuration(h, r);
    if who <> 0 then begin
        r[who].HealthPoint := r[who].HealthPoint - 1;
        r[who].IsAgression := true;
        if r[who].HealthPoint = 0 then begin
            r[who].IsLived := false;
            HideRat(r[who], h, field)
        end
    end

end;

procedure HitHero(var h: Hero; var field: Gfield; var r: ArrayRats; ShiftX, ShiftY: integer);
begin
    if (ord(h.condition) <> 2) and (ord(h.condition) <> 5) then begin
        if ord(h.condition) < 2 then
            h.condition := HcBackHit
        else if ord(h.condition) <> 5 then
            h.condition := HcFrontHit;
        h.HitTimer := now;
        ToKill(h, r, field);
        RewritePartField(field, h, r, ShiftX, ShiftY)
    end
end;

procedure EndHitHero(var h: Hero; var field: Gfield; var stack: TaskStack; var r: ArrayRats; ShiftX, ShiftY: integer);
var
    t: TDateTime;
begin
    t := now;
    if (MillisecondsBetween(h.HitTimer, t) > 300) and
        ((h.condition = HcBackHit) or (h.condition = HcFrontHit)) then begin
            h.condition := HeroCondition(ord(h.condition) - 1);
            RewritePartField(field, h, r, ShiftX, ShiftY)
        end
    else if (h.condition = HcBackHit) or (h.condition = HcFrontHit) then
        TsPush(stack, EndHit, 0)
end;

end.
