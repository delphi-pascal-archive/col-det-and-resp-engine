unit _util;

interface
function StrToFloatDef(strValue : String; defValue : Single{Extended}) : Single{Extended};

implementation
uses strings;

function StrToFloatDef(strValue : String; defValue : Single{Extended}) : Single{Extended};
var
   i, divider, lLen : Integer;
   c : Char;
begin
   Result:=0;
   if strValue='' then Exit;
   divider:=MaxInt;
   strValue:=Trim(StrValue);
   lLen:=length(strValue);
  for i:=1 to lLen do begin
      c:=strValue[i];
      case c of
         '0'..'9' : Result:=(Result*10)+Integer(c)-Integer('0');
         ',', '.' : begin
            if (divider=MaxInt) then
               divider:=i
            else begin
               Result:=defValue;
               Exit;
            end;
         end;
         '-', '+' : if i>1 then begin
            Result:=defValue;
            Exit;
         end;
    else
         if (c<>' ') or (divider<>MaxInt) then begin
            Result:=defValue;
            Exit;
         end;
      end;
   end;
   divider:=lLen-divider;
   if divider>0 then Result:=Result*Exp(-divider*Ln(10));
   if (strValue[1]='-') then Result:=-Result;
end;

end.