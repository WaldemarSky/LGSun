unit MovPrintChar;               {movprintchar.pp}

interface
procedure GetKey(var code: integer);
procedure ShowChar (ch: char; {bg, fg: word;} x, y: integer);

implementation
uses crt;

procedure GetKey(var code: integer);
var
    c: char;
begin
    c := ReadKey;
    if c = #0 then begin
        c := ReadKey;
        code := -ord(c)
    end
    else begin
        code := ord(c)
    end
end;

procedure ShowChar (ch: char; {bg, fg: word;} x, y: integer);
begin
    // TextBackground(bg);
    // TextColor(fg);
    GotoXY(x, y);
    write(ch)
end;

end.
