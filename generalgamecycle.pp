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
uses crt, StartEndGame, MovPrintHero, MovPrintChar, TaskStackUnit, GameField;

procedure DoFromQueue(var stack: TaskStack; var h: hero; field: Gfield; ShiftX, ShiftY: integer);
var
    TaskTop: tasks;
begin
    if not TSIsEmpty(stack) then begin
        TSPop(stack, TaskTop);
        case TaskTop of
        MvLeft: MoveHero(h, field, -1, 0, ShiftX, ShiftY);
        MvRight: MoveHero(h, field, 1, 0, ShiftX, ShiftY);
        MvUp: MoveHero(h, field, 0, -1, ShiftX, ShiftY);
        MvDown: MoveHero(h, field, 0, 1, ShiftX, ShiftY);
        end;
        RewriteField(field, h, ShiftX, ShiftY);
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
    i: longint = 1;                     {counter for close eyes}
    g: longint = 0;                     {counter for open eyes}
    ShiftFieldX: integer;
    ShiftFieldY: integer;

begin
    clrscr;
    ShiftFieldX := -ScreenWidth div 2;
    ShiftFieldY := -ScreenHeight div 2;
    TSInit(TStack);
    GFieldInit(field);
    HeroInit(h);
    HeroConditionListInit(h);
    HeroMapPrintingInit(h);
    RewriteField(field, h, ShiftFieldX, ShiftFieldY);
    ShowHero(h);  
    while true do begin
        if KeyPressed then begin
            GetKey(c);
            case c of
            LeftButton: TSPush(TStack, MvLeft);
            RightButton: TSPush(TStack, MvRight);
            UpButton: TSPush(TStack, MvUp);
            DownButton: TSPush(TStack, MvDown);
            EndButton: ToEndGame;
            end;
            DoFromQueue(TStack, h, field, ShiftFieldX, ShiftFieldY)
        end
    end
end;

end.
