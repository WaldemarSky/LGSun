unit TaskStackUnit;                     {taskstackunit.pp}

interface
type
    tasks = (MvLeft, MvRight, MvUp, MvDown, DhBlink);
    
    TaskPtr = ^task;
    task = record
        effect: tasks;
        next: TaskPtr;
    end;

    TaskStack = TaskPtr;

procedure TSInit(var stack: TaskStack);
procedure TSPush(var stack: TaskStack; t: tasks);
procedure TSPop(var stack: TaskStack; var t: tasks);
function TSIsEmpty(var stack: TaskStack): boolean;

implementation

procedure TSInit(var stack: TaskStack);
begin
    stack := nil;
end;

procedure TSPush(var stack: TaskStack; t: tasks);
var
    tmp: TaskPtr;
begin
    new(tmp);
    tmp^.effect := t;
    tmp^.next := stack;
    stack := tmp
end;

procedure TSPop(var stack: TaskStack; var t: tasks);
var
    tmp: TaskPtr;
begin
    t := stack^.effect;
    tmp := stack;
    stack := stack^.next;
    dispose(tmp)
end;

function TSIsEmpty(var stack: TaskStack): boolean;
begin
    TSIsEmpty := stack=nil
end;

end.
