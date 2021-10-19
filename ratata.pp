unit Ratata;                    {rat.pp}

interface
uses MovPrintHero, SysUtils, TaskStackUnit;
const
    RatCount = 7;
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
procedure DoRatsTurn(var h: hero; var stack: TaskStack; var rats: ArrayRats);
function IsInsideVision(x, y: integer): boolean;
function IsHitRatDistantion(var r: rat; var h: hero): boolean;

implementation
uses crt, DateUtils;
procedure ArrayRatsInit(var rats: ArrayRats);
begin
    rats[1].IsLived := true;
    rats[1].HealthPoint := 3;
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
    rats[3].IsAgression := false;

    rats[4].IsLived := true;
    rats[4].HealthPoint := 3;
    rats[4].x := 57;
    rats[4].y := -54;
    rats[4].MoveTimer := Now;
    rats[4].Duration := RatPrintLeft;
    rats[4].IsAgression := false;

    rats[5].IsLived := true;
    rats[5].HealthPoint := 3;
    rats[5].x := 93;
    rats[5].y := -30;
    rats[5].MoveTimer := Now;
    rats[5].Duration := RatPrintLeft;
    rats[5].IsAgression := false;

    rats[6].IsLived := true;
    rats[6].HealthPoint := 3;
    rats[6].x := 97;
    rats[6].y := -16;
    rats[6].MoveTimer := Now;
    rats[6].Duration := RatPrintLeft;
    rats[6].IsAgression := false;

    rats[7].IsLived := true;
    rats[7].HealthPoint := 3;
    rats[7].x := 93;
    rats[7].y := -15;
    rats[7].MoveTimer := Now;
    rats[7].Duration := RatPrintLeft;
    rats[7].IsAgression := false
end;

function IsInsideVision(x, y: integer): boolean;
begin
    IsInsideVision := (x > 0) and (x <= ScreenWidth) and
        (y > 1) and (y < ScreenHeight)
end;


function IsHitRatDistantion(var r: rat; var h: hero): boolean;
var
    yb, xb: boolean;
    x, y: integer;
begin
    for y := (h.y - 1) to (h.y + 2) do
        if y = r.y then begin
            yb := true;
            break
        end;
    xb := (r.x = h.x - 7) or (r.x = h.x + 2);
    if yb and xb then begin
        IsHitRatDistantion := true;
        exit
    end;
    for x := (h.x - 5) to (h.x + 0) do
        if x = r.x then begin
            xb := true; 
            break
        end;
    yb := (r.y = h.y - 2) or (r.y = h.y + 3);
    if yb and xb then begin
        IsHitRatDistantion := true;
        exit
    end;
    IsHitRatDistantion := false
end;

procedure DoRatsTurn(var h: hero; var stack: TaskStack; var rats: ArrayRats);
var
    t: TDateTime;
    i:integer;
    choice: real;
    x, y: integer;
begin
    for i := 1 to RatCount do begin
        t := now;
        if rats[i].IsLived then begin
            if MillisecondsBetween(rats[i].MoveTimer, t) > 1000 then begin
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
                    if IsHitRatDistantion(rats[i], h) then begin
                        h.HealthPoint := h.HealthPoint - 1;
                        WriteStatusBar(h)
                    end;
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
