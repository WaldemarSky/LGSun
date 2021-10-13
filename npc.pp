unit Npc;                        {npc.pp}


interface
uses SysUtils, GameField, MovPrintHero;
const
    NpcStringCount = 4;
    SMxOpEyDur = 5000;
    SMnOpEyDur = 700;
    SMxClEyDur = 350;
    SMnClEyDur = 80;
    SageSN = 3;

type
    NpcCondition = (NpcFront, NpcBlink);

    SageConditionlist = array[NpcCondition] of
        array[0..NpcStringCount] of string[10];


    Sage = record
        x, y: integer;
        CenX, CenY: integer;
        SCondList: SageConditionlist;
        condition: NpcCondition;
        BlinkTimer: TDateTime;
        OpEyDur: integer;
        ClEyDur: integer;
    end;

procedure NpcInit(var n: Sage; var field: Gfield);
procedure BlinkNpc(var n: Sage; var h: hero; var field: Gfield);

implementation
uses crt, DateUtils;

procedure NpcConditionListInit(var n: Sage);
begin
    n.SCondList[NpcFront, 0] := '   ^';
    n.SCondList[NpcFront, 1] := ' _/_\_';
    n.SCondList[NpcFront, 2] := '.(*_*).';
    n.SCondList[NpcFront, 3] := '/&#"#&\';
    n.SCondList[NpcFront, 4] := '|"$^$"|';
    
    n.SCondList[NpcBlink, 0] := '   ^';
    n.SCondList[NpcBlink, 1] := ' _/_\_';
    n.SCondList[NpcBlink, 2] := '.(-_-).';
    n.SCondList[NpcBlink, 3] := '/&#"#&\';
    n.SCondList[NpcBlink, 4] := '|"$^$"|'
end;


procedure InitNpcAttend(var n: Sage; var field: Gfield);
var
    x, y: integer;
begin
    for y := 0 to NpcStringCount do
        for x := 1 to length(n.SCondList[n.condition, y]) do begin
            if n.SCondList[n.condition, y][x] = ' ' then begin
                continue
            end;
            field[n.x + x - 1, n.y + y].attend := SageSN;
            field[n.x + x - 1, n.y + y].ch := n.SCondList[n.condition, y][x]
        end
end;

procedure NpcInit(var n: Sage; var field: Gfield);
begin
    n.x := 176;
    n.y := -23;
    n.CenX := ScreenWidth div 2;
    n.CenY := ScreenHeight div 2;
    NpcConditionListInit(n);
    n.condition := NpcFront;
    n.BlinkTimer := now;
    n.OpEyDur := random(SMxOpEyDur - SMnOpEyDur + 1) + SMnOpEyDur;
    n.ClEyDur := random(SMxClEyDur - SMnClEyDur + 1) + SMnClEyDur;
    InitNpcAttend(n, field)
end;

procedure BlinkNpc(var n: Sage; var h: hero; var field: Gfield);
var
    t: TDateTime;
begin
    t := now;
    if n.condition = NpcFront then begin
        if MillisecondsBetween(n.BlinkTimer, t) > n.OpEyDur then begin
            n.OpEyDur := random(SMxOpEyDur - SMnOpEyDur + 1) + SMnOpEyDur;
            n.BlinkTimer := t;
            n.condition := NpcCondition(ord(n.condition) + 1);
            InitNpcAttend(n, field);
            RewriteAreaField(field, h, n.x, n.y, n.x + 5, n.y + 5)
        end
    end
    else begin
        if MillisecondsBetween(n.BlinkTimer, t) > n.ClEyDur then begin
            n.ClEyDur := random(SMxClEyDur - SMnClEyDur + 1) + SMnClEyDur;
            n.BlinkTimer := t;
            n.condition := NpcCondition(ord(n.condition) - 1);
            InitNpcAttend(n, field);
            RewriteAreaField(field, h, n.x, n.y, n.x + 5, n.y + 5)
        end
    end
end;

end.
