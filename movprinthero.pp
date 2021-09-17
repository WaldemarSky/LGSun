unit MovPrintHero;                      {movprinthero.pp}

interface
const
    HStringCount = 4;
    LenghtHeroString = 9;

type
    HeroCondition = (HcUpFirst, HcUpSecond, HcDownFirst, HcDownSecond,
        HcDownFirstBlink, HcDownSecondBlink);

    HeroDuration = (HdUp, HdDown);

    HeroConditionsList = array[HeroCondition]
        of array [1..HstringCount] of string[LenghtHeroString];


    Hero = record
        CenX, CenY: integer;
        HCondList: HeroConditionsList; 
        x, y: integer;
        condition: HeroCondition;
    end;

procedure HeroInit(var h: Hero);
procedure HeroConditionListInit(var h: Hero);
procedure ShowHero(var h: Hero);
procedure MoveHero(var h: hero; x, y: integer);

implementation
uses crt, StartEndGame, MovPrintChar;

procedure HeroInit(var h: Hero);
begin
    h.CenX := (ScreenWidth - LenghtHeroString) div 2;
    h.CenY := ScreenHeight div 2;
    h.x := 0; 
    h.y := 0;
    h.condition := HcDownFirst
end;

procedure HeroConditionListInit(var h: Hero);
begin
    h.HcondList[HcUpFirst, 1] := '  _---_  ';
    h.HcondList[HcUpFirst, 2] := '\ \\|//  ';
    h.HcondList[HcUpFirst, 3] := ' \#&&&#  ';
    h.HcondList[HcUpFirst, 4] := '   #^$   ';
    
    h.HcondList[HcUpSecond, 1] := '  _---_  ';
    h.HcondList[HcUpSecond, 2] := '\ \\|//  ';
    h.HcondList[HcUpSecond, 3] := ' \#&&&#  ';
    h.HcondList[HcUpSecond, 4] := '   $^#^  ';

    h.HcondList[HcDownFirst, 1] := '  _---_  ';
    h.HcondList[HcDownFirst, 2] := '  \*_*/ /';
    h.HcondList[HcDownFirst, 3] := '  #&@&#/ ';
    h.HcondList[HcDownFirst, 4] := '  ^$^#   ';

    h.HcondList[HcDownSecond, 1] := '  _---_  ';
    h.HcondList[HcDownSecond, 2] := '  \*_*/ /';
    h.HcondList[HcDownSecond, 3] := '  #&@&#/ ';
    h.HcondList[HcDownSecond, 4] := '   #^$   ';

    h.HcondList[HcDownFirstBlink, 1] := '  _---_  ';
    h.HcondList[HcDownFirstBlink, 2] := '  \-_-/ /';
    h.HcondList[HcDownFirstBlink, 3] := '  #&@&#/ ';
    h.HcondList[HcDownFirstBlink, 4] := '  ^$^#   ';

    h.HcondList[HcDownSecondBlink, 1] := '  _---_  ';
    h.HcondList[HcDownSecondBlink, 2] := '  \-_-/ /';
    h.HcondList[HcDownSecondBlink, 3] := '  #&@&#/ ';
    h.HcondList[HcDownSecondBlink, 4] := '   #^$   '
end;


procedure ShowHero(var h: Hero);
var
    i, g: integer;
begin
    g := 1;
    for i := -2 to 1 do begin
        GotoXY(h.CenX, h.CenY+i);
        write(h.HCondList[h.condition, g]);
        g := g + 1
    end;
    GotoXY(1, 1)
end;

procedure HideHero(var h: Hero);
var
    i, g: integer;
begin
    g := 1;
    for i := -2 to 1 do begin
        GotoXY(h.CenX-2, h.CenY+i);
        write('    ');
        g := g + 1
    end;
    GotoXY(1, 1)
end;

procedure MoveHero(var h: hero; x, y: integer);
begin
    HideHero(h);
    // if not IsBarrier then begin
        h.x := h.x + x;
        h.y := h.y + y;
        if (y = -1) and (ord(h.condition) > 1) then
            h.condition := HcUpFirst; 
        if (y = 1) and (ord(h.condition) < 2) then
            h.condition := HcDownFirst; 
        if ord(h.condition) mod 2 = 0 then
            h.condition := succ(h.condition) 
        else
            h.condition := pred(h.condition);
        ShowHero(h)
    // end
end;

end.
