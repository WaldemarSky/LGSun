unit GeneralGameCycle;                       {generalgamecycle.pp}

interface
const
    LeftButton = -75;
    RightButton = -77;
    UpButton = -72;
    DownButton = -80;
    EndButton = 27;
    HitButton = 113;

procedure GeneralCycle;

implementation
uses crt, SysUtils, DateUtils, StartEndGame, MovPrintHero,
    MovPrintChar, TaskStackUnit, Lanterns, GameField, Ratata, Npc;

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

procedure DoBlinkHero(var h: hero);
var
    t: TDateTime;
begin
    t := now;
    if (h.condition = HcFrontFirst) or (h.condition = HcFrontSecond) then begin
        if MillisecondsBetween(h.BlinkTimer, t) > h.OpEyDur then begin
            h.OpEyDur := random(MxOpEyDur - MnOpEyDur + 1) + MnOpEyDur;
            h.BlinkTimer := t;
            h.condition := HeroCondition(ord(h.condition) + 3);
            ShowHero(h)
        end
    end
    else if (h.condition = HcFirstBlink)
        or (h.condition = HcSecondBlink) then begin
        if MillisecondsBetween(h.BlinkTimer, t) > h.ClEyDur then begin
            h.ClEyDur := random(MxClEyDur - MnClEyDur + 1) + MnClEyDur;
            h.BlinkTimer := t;
            h.condition := HeroCondition(ord(h.condition) - 3);
            ShowHero(h)
        end
    end
end;


procedure GeneralCycle;
var
    c: integer;
    h: Hero;
    TStack: TaskStack;
    LStack: LanternStack;
    field: GField;
    TxArray: TextureArray;
    rats: ArrayRats;
    npc: Sage;
    ShiftFieldX: integer;
    ShiftFieldY: integer;
    l: integer;
begin
    clrscr;
    randomize;
    ShiftFieldX := -ScreenWidth div 2;
    ShiftFieldY := -ScreenHeight div 2;
    TSInit(TStack);
    LSInit(Lstack);
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
    while true do begin
        DoFromQueue(TStack, h, rats, field, ShiftFieldX, ShiftFieldY);
        DoRatsTurn(h, TStack, rats);
        DoBlinkHero(h);
        BlinkNpc(npc, h, field);
        if KeyPressed then begin
            GetKey(c);
            case c of
            LeftButton: TSPush(TStack, MvLeft, 0);
            RightButton: TSPush(TStack, MvRight, 0);
            UpButton: TSPush(TStack, MvUp, 0);
            DownButton: TSPush(TStack, MvDown, 0);
            HitButton: DoHit(Tstack, h, rats);
            EndButton: ToEndGame;
            end
        end;
        if h.HealthPoint = 0 then
            GameOver
    end
end;

end.
