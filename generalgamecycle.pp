unit GeneralGameCycle;                       {generalgamecycle.pp}

interface
const
    LeftButton = -75;
    RightButton = -77;
    UpButton = -72;
    DownButton = -80;
    EndButton = 27;

procedure GeneralCycle;

implementation
uses crt, StartEndGame, MovPrintHero, MovPrintChar, TaskStackUnit, GameField, Ratata;

procedure DoFromQueue(var stack: TaskStack; var h: hero; var r: ArrayRats; field: Gfield; ShiftX, ShiftY: integer);
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

        RtLeft: MoveRat(r[who], field, -1, 0);
        RtRight: MoveRat(r[who], field, 1, 0);
        RtUp: MoveRat(r[who], field, 0, -1);
        RtDown: MoveRat(r[who], field, 0, 1)
        end;
        RewriteField(field, h, r, ShiftX, ShiftY);
        GotoXY(1, 1);
        write('x: ', h.x, '  ', 'y: ', h.y, '       ')
    end
end;

procedure DoBlink(var h: hero);
begin
    if (ord(h.condition) < 4) and (ord(h.condition) > 1) then begin
        h.condition := succ (succ(h.condition));
        ShowHero(h)
    end
    else if ord(h.condition) >= 4 then begin
        h.condition := pred(pred(h.condition));
        ShowHero(h);
    end
end;

procedure BlinkHero(var h: hero; var CCounter, OCounter: longint);
begin
    if  CCounter <> 0 then
        CCounter := CCounter + 1;
    if CCounter > 80000 then begin
        DoBlink(h);
        CCounter := 0
    end;
    if CCounter = 0 then begin
        OCounter := OCounter + 1;
        if OCounter = 6000 then begin
            DoBlink(h);
            CCounter := 1;
            OCounter := 0
        end
    end
end;

procedure GeneralCycle;
var
    c: integer;
    h: Hero;
    TStack: TaskStack;
    field: GField;
    rats: ArrayRats;
    i: longint = 1;                     {counter for close eyes}
    g: longint = 0;                     {counter for open eyes}
    ShiftFieldX: integer;
    ShiftFieldY: integer;

begin
    clrscr;
    randomize;
    ShiftFieldX := -ScreenWidth div 2;
    ShiftFieldY := -ScreenHeight div 2;
    TSInit(TStack);
    GFieldInit(field);
    HeroInit(h);
    HeroConditionListInit(h);
    HeroMapPrintingInit(h);
    ArrayRatsInit(rats);
    RewriteField(field, h, rats, ShiftFieldX, ShiftFieldY);
    while true do begin
        DoFromQueue(TStack, h, rats, field, ShiftFieldX, ShiftFieldY);
        DoRatsTurn(TStack, rats);
        if KeyPressed then begin
            GetKey(c);
            case c of
            LeftButton: TSPush(TStack, MvLeft, 0);
            RightButton: TSPush(TStack, MvRight, 0);
            UpButton: TSPush(TStack, MvUp, 0);
            DownButton: TSPush(TStack, MvDown, 0);
            EndButton: ToEndGame;
            end
        end
    end
end;

end.
