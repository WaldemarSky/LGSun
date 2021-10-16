Unit Lanterns;                      {lanterns.pp}

interface
type
    LanternPtr = ^Lantern;

    Lantern = record
        x, y: integer;
        next: LanternPtr;
    end;

    LanternStack = LanternPtr;

procedure LSInit(var stack: LanternStack);
procedure LSPush(var stack: LanternStack; x, y: integer);

implementation
procedure LSInit(var stack: LanternStack);
begin
    stack := nil;
end;

procedure LSPush(var stack: LanternStack; x, y: integer);
var
    tmp: LanternPtr;
begin
    new(tmp);
    tmp^.x := x;
    tmp^.y := y;
    tmp^.next := stack;
    stack := tmp
end;

// procedure LSPop(var stack: TaskStack; var t: tasks; var w: integer);
// var
//     tmp: TaskPtr;
// begin
//     t := stack^.effect;
//     w := stack^.who;
//     tmp := stack;
//     stack := stack^.next;
//     dispose(tmp)
// end;

end.
