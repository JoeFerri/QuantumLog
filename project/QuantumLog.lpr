{
    This file is part of the QuantumLog Program.
    Copyright (c) 2025 Giuseppe Ferri

    Moral rights:
      Giuseppe Ferri <jfinfoit@gmail.com>

    See the file LICENSE, included in this distribution,
    for details about the copyright.

 **********************************************************************}

program QuantumLog;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar:=True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

