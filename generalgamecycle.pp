unit GeneralGameCycle;                       {generalgamecycle.pp}

interface
const
    LeftButton = -75;
    RightButton = -77;
    UpButton = -72;
    DownButton = -80;
    EndButton = 27;
    HitButton = 113;
    FlameButton = 119;

    StartMessage = 'How long have I slept?'#10'In the world of eternal darkness, it is difficult to judge this';
    CampMessage = 'The fire from the last dinner has not burned yet'#10'The rat was very tasty';
    RatMessage = 'Rats.....'#10'So ugly, but so delitious';
    SageMessage = 'The gods of the vast space have not yet finished'#10'creating our world'#10'Please, come back later';

procedure GeneralCycle;

implementation
uses crt, SysUtils, DateUtils, StartEndGame, MovPrintHero,
    MovPrintChar, TaskStackUnit, Lanterns, GameField, Ratata, Npc;

type
    ArrayTW = array[1..8] of string;

procedure ArrayTWInit(var a: ArrayTW);
begin
    a[1] := '_____________________________________________________________________________';
    a[2] := '|                                                                             |';
    a[3] := '|                                                                             |';
    a[4] := '|                                                                             |';
    a[5] := '|                                                                             |';
    a[6] := '|                                                                             |';
    a[7] := '|                                                                             |';
    a[8] := '-----------------------------------------------------------------------------'
end;

procedure DoTextWindow(s: string; a: ArrayTW);
var
    Ygap: integer = -10;
    i: integer;
    ch: char;
begin
    TextColor(White);
    for i := 1 to length(a) do begin
        GotoXY((ScreenWidth - length(a[i])) div 2, ScreenHeight div 2 + Ygap);
        write(a[i]);
        Ygap := Ygap + 1
    end;
    Ygap := -8;
    GotoXY(ScreenWidth div 4, ScreenHeight div 2 + Ygap);
    for ch in s do begin
        if ch = #10 then begin
            Ygap := Ygap + 1;
            GotoXY(ScreenWidth div 4, ScreenHeight div 2 + Ygap);
            delay(1500)
        end
        else begin
            write(ch);
            delay(75)
        end;
    end;
    delay(1500);
end;

procedure DoHit(var stack: TaskStack; var h: hero; var r: ArrayRats);
begin
    TsPush(stack, EndHit, 0);
    TsPush(stack, StartHit, 0);
end;

procedure DoFromQueue(var stack: TaskStack; var h: hero; var r: ArrayRats; var field: Gfield; ShiftX, ShiftY: integer);
var
    TaskTop: tasks;
    who: integer;
begin
    if not TSIsEmpty(stack) then begin
        TSPop(stack, TaskTop, who);
        case TaskTop of
        MvLeft: MoveHero(h, r, field, -1, 0, ShiftX, ShiftY);
        MvRight: MoveHero(h, r, field, 1, 0, ShiftX, ShiftY);
        MvUp: MoveHero(h, r, field, 0, -1, ShiftX, ShiftY);
        MvDown: MoveHero(h, r, field, 0, 1, ShiftX, ShiftY);
        StartHit: HitHero(h, field, r, ShiftX, ShiftY);
        EndHit: EndHitHero(h, field, stack, r, ShiftX, ShiftY);

        RtLeft: MoveRat(r[who], h, field, -1, 0);
        RtRight: MoveRat(r[who],h, field, 1, 0);
        RtUp: MoveRat(r[who], h, field, 0, -1);
        RtDown: MoveRat(r[who], h, field, 0, 1)
        end;
    end
end;

procedure DoBlinkHero(var h: hero; var field: Gfield);
var
    t: TDateTime;
begin
    t := now;
    if (h.condition = HcFrontFirst) or (h.condition = HcFrontSecond) then begin
        if MillisecondsBetween(h.BlinkTimer, t) > h.OpEyDur then begin
            h.OpEyDur := random(MxOpEyDur - MnOpEyDur + 1) + MnOpEyDur;
            h.BlinkTimer := t;
            h.condition := HeroCondition(ord(h.condition) + 3);
            ShowHero(h, field)
        end
    end
    else if (h.condition = HcFirstBlink)
        or (h.condition = HcSecondBlink) then begin
        if MillisecondsBetween(h.BlinkTimer, t) > h.ClEyDur then begin
            h.ClEyDur := random(MxClEyDur - MnClEyDur + 1) + MnClEyDur;
            h.BlinkTimer := t;
            h.condition := HeroCondition(ord(h.condition) - 3);
            ShowHero(h, field)
        end
    end
end;

procedure DoFlame(var h: hero; var field: Gfield; var r: ArrayRats; ShiftX, ShiftY: integer);
begin
    case h.FlamePoint of
    false: begin
        h.FlamePoint := true;
        h.HcondList[HcBackFirst, 2][1] := '*';
        h.HcondList[HcBackSecond, 2][1] := '*';
        h.HcondList[HcFrontFirst, 2][7] := '*';
        h.HcondList[HcFrontSecond, 2][7] := '*';
        h.HcondList[HcFirstBlink, 2][7] := '*';
        h.HcondList[HcSecondBlink, 2][7] := '*'
    end;
    true: begin
        h.FlamePoint := false;
        h.HcondList[HcBackFirst, 2][1] := '\';
        h.HcondList[HcBackSecond, 2][1] := '\';
        h.HcondList[HcFrontFirst, 2][7] := '/';
        h.HcondList[HcFrontSecond, 2][7] := '/';
        h.HcondList[HcFirstBlink, 2][7] := '/';
        h.HcondList[HcSecondBlink, 2][7] := '/'
    end
    end;
    InitHeroLight(h, field);
    RewriteField(field, h, r, ShiftX, ShiftY)
end;

procedure GeneralCycle;
var
    c: integer;
    h: Hero;
    TStack: TaskStack;
    LStack: LanternStack;
    a: ArrayTW;
    field: GField;
    TxArray: TextureArray;
    rats: ArrayRats;
    npc: Sage;
    ShiftFieldX: integer;
    ShiftFieldY: integer;
    l: integer;
    WindowFlag: boolean = true;
begin
    clrscr;
    randomize;
    ShiftFieldX := -ScreenWidth div 2;
    ShiftFieldY := -ScreenHeight div 2;
    TSInit(TStack);
    LSInit(Lstack);
    ArrayTWInit(a);
    GFieldInit(field, TxArray, LStack);
    HeroInit(h);
    HeroConditionListInit(h);
    HeroMapPrintingInit(h);
    InitHeroAttend(h, field, HeroSN);
    ArrayRatsInit(rats);
    for l := 1 to RatCount do
        InitRatAttend(rats[l],field, RatSN);
    NpcInit(npc, field);
    RewriteField(field, h, rats, ShiftFieldX, ShiftFieldY);
    WriteStatusBar(h);
    DoTextWindow(StartMessage, a);
    RewriteField(field, h, rats, ShiftFieldX, ShiftFieldY);
    while true do begin
        DoFromQueue(TStack, h, rats, field, ShiftFieldX, ShiftFieldY);
        DoRatsTurn(h, TStack, rats);
        DoBlinkHero(h, field);
        BlinkNpc(npc, h, field);
        if (h.x = -11) and (h.y = -11) and (WindowFlag = true) then begin
            DoTextWindow(CampMessage, a);
            RewriteField(field, h, rats, ShiftFieldX, ShiftFieldY);
            WindowFlag := false
        end;
        if (h.x = 75) and (h.y = -26) and (WindowFlag = true) then begin
            DoTextWindow(RatMessage, a);
            RewriteField(field, h, rats, ShiftFieldX, ShiftFieldY);
            WindowFlag := false
        end;
        if (h.x = 168) and (h.y = -21) and (WindowFlag = true) then begin
            DoTextWindow(SageMessage, a);
            RewriteField(field, h, rats, ShiftFieldX, ShiftFieldY);
            WindowFlag := false
        end;
        if KeyPressed then begin
            WindowFlag := true;
            GetKey(c);
            case c of
            LeftButton: TSPush(TStack, MvLeft, 0);
            RightButton: TSPush(TStack, MvRight, 0);
            UpButton: TSPush(TStack, MvUp, 0);
            DownButton: TSPush(TStack, MvDown, 0);
            HitButton:
                if not h.FlamePoint then
                    DoHit(Tstack, h, rats);
            FlameButton: DoFlame(h, field, rats, ShiftFieldX, ShiftFieldY);
            EndButton: ToEndGame;
            end
        end;
        if h.HealthPoint = 0 then
            GameOver
    end
end;

end.
