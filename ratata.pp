unit Ratata;                    {rat.pp}

interface
uses MovPrintHero, SysUtils, TaskStackUnit;
const
    RatCount = 3;
    RatPrintLeft = ',^@/';
    RatPrintRight = '\@^,';
type
    rat = record
        IsLived: boolean;
        HealthPoint: byte;
        x, y: integer;
        MoveTimer: TDateTime;
        Duration: string[4];
        IsAgression: boolean;
    end;

    ArrayRats = array [1..RatCount] of rat;

procedure ArrayRatsInit(var rats: ArrayRats);
procedure ShowRats(var rats: ArrayRats; var h: hero);
procedure ShowRat(var r: rat; var h: hero);
procedure DoRatsTurn(var h: hero; var stack: TaskStack; var rats: ArrayRats);
function IsInsideVision(x, y: integer): boolean;

implementation
uses crt, DateUtils;
procedure ArrayRatsInit(var rats: ArrayRats);
begin
    rats[1].IsLived := true;
    rats[1].HealthPoint := 7;
    rats[1].x := 40;
    rats[1].y := -40;
    rats[1].MoveTimer := Now;
    rats[1].Duration := RatPrintLeft;
    rats[1].IsAgression := false;

    rats[2].IsLived := true;
    rats[2].HealthPoint := 3;
    rats[2].x := 77;
    rats[2].y := -45;
    rats[2].MoveTimer := Now;
    rats[2].Duration := RatPrintLeft;
    rats[2].IsAgression := false;

    rats[3].IsLived := true;
    rats[3].HealthPoint := 3;
    rats[3].x := 57;
    rats[3].y := -54;
    rats[3].MoveTimer := Now;
    rats[3].Duration := RatPrintLeft;
    rats[3].IsAgression := false
end;

function IsInsideVision(x, y: integer): boolean;
begin
    IsInsideVision := (x > 0) and (x <= ScreenWidth) and
        (y > 0) and (y < ScreenHeight)
end;

procedure ShowRats(var rats: ArrayRats; var h: hero);
var
    i: integer;
begin
    for i := 1 to RatCount do
        if rats[i].IsLived then
            ShowRat(rats[i], h);
end;

procedure ShowRat(var r: rat; var h: hero);
var
    x, y: integer;
begin
    x := h.CenXField + r.x - h.x;
    y := h.CenY + r.y - h.y;
    if IsInsideVision(x, y) then begin
        GotoXY(x, y);
        write(r.Duration)
    end
end;

procedure DoRatsTurn(var h: hero; var stack: TaskStack; var rats: ArrayRats);
var
    t: TDateTime;
    i:integer;
    choice: real;
    x, y: integer;
begin
    for i := 1 to RatCount do begin
        if rats[i].IsLived then begin
            t := now;
            if MillisecondsBetween(rats[i].MoveTimer, t) > 1800 then begin
                rats[i].MoveTimer := t;
                if rats[i].IsAgression = false then begin
                    choice := random;
                    if choice < 0.15 then
                        TsPush(stack, RtLeft, i)
                    else if (choice >= 0.15) and (choice < 0.30) then
                        TsPush(stack, RtRight, i)
                    else if (choice >= 0.30) and (choice < 0.45) then
                        TsPush(stack, RtDown, i)
                    else if (choice >= 0.45) and (choice < 0.60) then
                        TsPush(stack, RtUp, i)
                end
                else begin
                    x := rats[i].x - h.x;
                    if x < 0 then
                        TsPush(stack, RtRight, i)
                    else
                        TsPush(stack, RtLeft, i);
                    y := rats[i].y - h.y;
                    if y < 0 then
                        TsPush(stack, RtDown, i)
                    else
                        TsPush(stack, RtUp, i);
                end
            end
        end
    end
end;

end.
