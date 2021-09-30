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
    end;

    ArrayRats = array [1..RatCount] of rat;

procedure ArrayRatsInit(var rats: ArrayRats);
procedure ShowRats(var rats: ArrayRats; var h: hero);
procedure DoRatsTurn(var stack: TaskStack; var rats: ArrayRats);

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

    rats[2].IsLived := true;
    rats[2].HealthPoint := 3;
    rats[2].x := 77;
    rats[2].y := -45;
    rats[2].MoveTimer := Now;
    rats[2].Duration := RatPrintLeft;

    rats[3].IsLived := true;
    rats[3].HealthPoint := 3;
    rats[3].x := 57;
    rats[3].y := -54;
    rats[3].MoveTimer := Now;
    rats[3].Duration := RatPrintLeft;
end;

function IsInsideVision(x, y: integer): boolean;
begin
    IsInsideVision := (x > 0) and (x <= ScreenWidth) and
        (y > 0) and (y <= ScreenHeight)
end;

procedure ShowRats(var rats: ArrayRats; var h: hero);
var
    i: integer;
    x, y: integer;
begin
    for i := 1 to RatCount do
        if rats[i].IsLived then begin
            x := h.CenXField + rats[i].x - h.x;
            y := h.CenY + rats[i].y - h.y;
            if IsInsideVision(x, y) then begin
                GotoXY(h.CenXField + rats[i].x - h.x, h.CenY + rats[i].y - h.y);
                write(rats[i].Duration)
            end
        end
end;

procedure DoRatsTurn(var stack: TaskStack; var rats: ArrayRats);
var
    t: TDateTime;
    i:integer;
    choice: real;
begin

    for i := 1 to RatCount do begin
        t := now;
        if MillisecondsBetween(rats[i].MoveTimer, t) > 400 then begin
            rats[i].MoveTimer := t;
            choice := random;
            if choice < 0.15 then
                TsPush(stack, RtLeft, i)
            else if (choice >= 0.15) and (choice < 0.30) then
                TsPush(stack, RtRight, i)
            else if (choice >= 0.30) and (choice < 0.45) then
                TsPush(stack, RtUp, i)
            else if (choice >= 0.45) and (choice < 0.60) then
                TsPush(stack, RtDown, i)
        end
    end
end;

end.
