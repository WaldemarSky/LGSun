unit TaskStackUnit;                     {taskstackunit.pp}

interface
type
    tasks = (MvLeft, MvRight, MvUp, MvDown, DhBlink, RtLeft, RtRight, RtUp, RtDown);
    
    TaskPtr = ^task;
    task = record
        effect: tasks;
        who: integer;
        next: TaskPtr;
    end;

    TaskStack = TaskPtr;

procedure TSInit(var stack: TaskStack);
procedure TSPush(var stack: TaskStack; t: tasks; w: integer);
procedure TSPop(var stack: TaskStack; var t: tasks; var w: integer);
function TSIsEmpty(var stack: TaskStack): boolean;

implementation

procedure TSInit(var stack: TaskStack);
begin
    stack := nil;
end;

procedure TSPush(var stack: TaskStack; t: tasks; w: integer);
var
    tmp: TaskPtr;
begin
    new(tmp);
    tmp^.effect := t;
    tmp^.who := w;
    tmp^.next := stack;
    stack := tmp
end;

procedure TSPop(var stack: TaskStack; var t: tasks; var w: integer);
var
    tmp: TaskPtr;
begin
    t := stack^.effect;
    w := stack^.who;
    tmp := stack;
    stack := stack^.next;
    dispose(tmp)
end;

function TSIsEmpty(var stack: TaskStack): boolean;
begin
    TSIsEmpty := stack=nil
end;

end.
