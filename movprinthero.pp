unit MovPrintHero;                      {movprinthero.pp}

interface
uses SysUtils;
const
    MaxHealthPoint = 10;
    HStringCount = 4;
    LenghtHeroString = 9;
    LeftHeroBorder = -4;
    RightHeroBorder = 2;
    UpHeroBorder = -2;
    DownHeroBorder = 3;
    MxOpEyDur = 4500;
    MnOpEyDur = 800;
    MxClEyDur = 300;
    MnClEyDur = 70;

type
    HeroDuration = (HdUp, HdLeft, HdDown, HdRight);
    HeroCondition = (HcBackFirst, HcBackSecond, HcBackHit, 
        HcFrontFirst, HcFrontSecond, HcFrontHit,
        HcFirstBlink, HcSecondBlink);

    HeroConditionsList = array[HeroCondition]
        of array [1..HstringCount] of string[LenghtHeroString];

    HeroMapPrinting = array[0..7, 1..HStringCount] of integer;

    Hero = record
        name: string[15];
        HealthPoint: byte;
        CenXfield, CenX, CenY: integer;
        HCondList: HeroConditionsList; 
        x, y: integer;
        duration: HeroDuration;
        condition: HeroCondition;
        PrintMap: HeroMapPrinting;
        BlinkTimer: TDateTime;
        OpEyDur: integer;
        ClEyDur: integer;
        HitTimer: TDateTime;
    end;

procedure HeroInit(var h: Hero);
procedure HeroConditionListInit(var h: Hero);
procedure HeroMapPrintingInit(var h: Hero);
procedure ShowHero(var h: Hero);
procedure WriteStatusBar(var h: hero);

implementation
uses crt, StartEndGame, MovPrintChar, GameField;

procedure HeroInit(var h: Hero);
begin
    h.name := 'Hero';
    h.HealthPoint := MaxHealthPoint;
    h.CenXfield := ScreenWidth div 2;
    h.CenX := (ScreenWidth - LenghtHeroString) div 2;
    h.CenY := ScreenHeight div 2;
    h.x := 0; 
    h.y := 0;
    h.duration := HdDown;
    h.condition := HcFrontFirst;
    h.BlinkTimer := now;
    h.OpEyDur := random(MxOpEyDur - MnOpEyDur + 1) + MnOpEyDur;
    h.ClEyDur := random(MxClEyDur - MnClEyDur + 1) + MnClEyDur;
end;

procedure HeroConditionListInit(var h: Hero);
begin
    h.HcondList[HcBackFirst, 1] := '_---_';
    h.HcondList[HcBackFirst, 2] := '\ \\|//';           {0}
    h.HcondList[HcBackFirst, 3] := '\#&&&#';
    h.HcondList[HcBackFirst, 4] := '#^$';
    
    h.HcondList[HcBackSecond, 1] := '_---_';
    h.HcondList[HcBackSecond, 2] := '\ \\|//';          {1}
    h.HcondList[HcBackSecond, 3] := '\#&&&#';
    h.HcondList[HcBackSecond, 4] := '$^#"';

    h.HcondList[HcBackHit, 1] := '_---_';
    h.HcondList[HcBackHit, 2] := '\\|//';
    h.HcondList[HcBackHit, 3] := '---#&&&#';            {2}
    h.HcondList[HcBackHit, 4] := '$^#"';

    h.HcondList[HcFrontFirst, 1] := '_---_';
    h.HcondList[HcFrontFirst, 2] := '\*_*/ /';          {3}
    h.HcondList[HcFrontFirst, 3] := '#&@&#/';
    h.HcondList[HcFrontFirst, 4] := '"$^#';

    h.HcondList[HcFrontSecond, 1] := '_---_';
    h.HcondList[HcFrontSecond, 2] := '\*_*/ /';         {4}
    h.HcondList[HcFrontSecond, 3] := '#&@&#/';
    h.HcondList[HcFrontSecond, 4] := '#^$';

    h.HcondList[HcFrontHit, 1] := '_---_';
    h.HcondList[HcFrontHit, 2] := '\*_*/';
    h.HcondList[HcFrontHit, 3] := '#&@&#---';           {5}
    h.HcondList[HcFrontHit, 4] := '"#^$';

    h.HcondList[HcFirstBlink, 1] := '_---_';
    h.HcondList[HcFirstBlink, 2] := '\-_-/ /';
    h.HcondList[HcFirstBlink, 3] := '#&@&#/';           {6}
    h.HcondList[HcFirstBlink, 4] := '"$^#';

    h.HcondList[HcSecondBlink, 1] := '_---_';
    h.HcondList[HcSecondBlink, 2] := '\-_-/ /';         {7}
    h.HcondList[HcSecondBlink, 3] := '#&@&#/ ';
    h.HcondList[HcSecondBlink, 4] := '#^$';
end;

procedure HeroMapPrintingInit(var h: Hero);
begin
    h.PrintMap[0][1] := 2; h.PrintMap[0][2] := 0;
    h.PrintMap[0][3] := 1; h.PrintMap[0][4] := 3;

    h.PrintMap[1][1] := 2; h.PrintMap[1][2] := 0;
    h.PrintMap[1][3] := 1; h.PrintMap[1][4] := 3;

    h.PrintMap[2][1] := 2; h.PrintMap[2][2] := 2;
    h.PrintMap[2][3] := -1; h.PrintMap[2][4] := 3;

    h.PrintMap[3][1] := 2; h.PrintMap[3][2] := 2;
    h.PrintMap[3][3] := 2; h.PrintMap[3][4] := 2;

    h.PrintMap[4][1] := 2; h.PrintMap[4][2] := 2;
    h.PrintMap[4][3] := 2; h.PrintMap[4][4] := 3;

    h.PrintMap[5][1] := 2; h.PrintMap[5][2] := 2;
    h.PrintMap[5][3] := 2; h.PrintMap[5][4] := 2;

    h.PrintMap[6][1] := 2; h.PrintMap[6][2] := 2;
    h.PrintMap[6][3] := 2; h.PrintMap[6][4] := 2;

    h.PrintMap[7][1] := 2; h.PrintMap[7][2] := 2;
    h.PrintMap[7][3] := 2; h.PrintMap[7][4] := 3
end;

procedure ShowHero(var h: Hero);
var
    i, g: integer;
begin
    g := 1;
    for i := -1 to 2 do begin
        GotoXY(h.CenX + h.PrintMap[ord(h.condition), g], h.CenY+i);
        write(h.HCondList[h.condition, g]);
        g := g + 1
    end;
    GotoXY(1, 1)
end;

procedure WriteStatusBar(var h: hero);
var
    i: integer;
begin
        GotoXY(1, 1);
        TextColor(White);
        write('   ',h.name, '     ');
        TextColor(Red);
        for i := 1 to MaxHealthPoint do 
            if i <= h.HealthPoint then
                write('<3 ')
            else
                write('   ');
            
        TextColor(LightGray);
        write('       ');
        write('x: ', h.x, '  ', 'y: ', h.y, '       ');
        GotoXY(1, 1)
end;

end.
