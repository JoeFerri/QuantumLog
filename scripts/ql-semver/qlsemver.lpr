{
    This file is part of the QuantumLog Program.
    Copyright (c) 2025 Giuseppe Ferri

    Moral rights:
      Giuseppe Ferri <jfinfoit@gmail.com>

    See the file LICENSE, included in this distribution,
    for details about the copyright.

 **********************************************************************}

program qlsemver;

{$mode objfpc}{$H+}

uses
  SysUtils, Classes, fpjson, jsonparser, DOM, XMLRead;

type
  TConfig = record
    qlSemverName: string;
    qlDiagramPath: string;
    qlLpiName: string;
    qlLpiPath: string;
    qlVersionName: string;
    qlVersionPath: string;
    authors: array of string;
    license: string;
    repository: string;
    preRelease: string;
  end;

  TVersionInfo = record
    major: Integer;
    minor: Integer;
    patch: Integer;
    debug: Boolean;
    preReleaseOK: Boolean;
    description: string;
    name: string;
    version: string;
  end;

var
  Config: TConfig;
  VersionInfo: TVersionInfo;

procedure ExitWithError(const AMessage: string);
begin
  WriteLn(StdErr, 'Error: ', AMessage);
  Halt(1);
end;

function LoadConfig: Boolean;
var
  ConfigFile: string;
  FS: TFileStream;
  JSONData: TJSONData;
  JSONObject: TJSONObject;
  JSONArray: TJSONArray;
  i: Integer;

  procedure freeData;
  begin
    if Assigned(FS) then
      FreeAndNil(FS);
    if Assigned(JSONData) then
      FreeAndNil(JSONData);
  end;
begin
  Result := False;
  ConfigFile := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'conf.json';

  if not FileExists(ConfigFile) then
    ExitWithError('Configuration file conf.json not found in program directory');

  FS := nil;
  try
    //! JSONData := GetJSON(TFileStream.Create(ConfigFile, fmOpenRead or fmShareDenyWrite));   <-- 94 byte of memory leak
    FS := TFileStream.Create(ConfigFile, fmOpenRead or fmShareDenyWrite);
    JSONData := GetJSON(FS);
    try
      if not (JSONData is TJSONObject) then
        raise Exception.Create('Invalid JSON structure in conf.json');

      JSONObject := TJSONObject(JSONData);

      // Load configuration values
      Config.qlSemverName := JSONObject.Get('ql-semver_name', '');
      Config.qlDiagramPath := JSONObject.Get('ql-diagram_path', '');
      Config.qlLpiName := JSONObject.Get('ql-lpi_name', '');
      Config.qlLpiPath := JSONObject.Get('ql-lpi_path', '');
      Config.qlVersionName := JSONObject.Get('ql-version_name', '');
      Config.qlVersionPath := JSONObject.Get('ql-version_path', '');
      Config.license := JSONObject.Get('license', '');
      Config.repository := JSONObject.Get('repository', '');
      Config.preRelease := JSONObject.Get('pre-release', '');

      // Load authors array
      //! JSONArray := JSONObject.Get('authors', TJSONArray(nil));   <-- 24 byte of memory leak
      JSONArray := JSONObject.Arrays['authors'];
      if Assigned(JSONArray) then
      begin
        SetLength(Config.authors, JSONArray.Count);
        for i := 0 to JSONArray.Count - 1 do
          Config.authors[i] := JSONArray.Strings[i];
      end;

      Result := True;
    finally
      freeData;
    end;
  except
    on E: Exception do
      begin
        freeData;
        ExitWithError('Error reading conf.json: ' + E.Message);
      end;
  end;
end;

function LoadLpiFile: Boolean;
var
  LpiFile: string;
  XMLDoc: TXMLDocument;
  VersionInfoNode, AttributesNode: TDOMNode;
  StringTableNode: TDOMNode;
  i: Integer;
  AttrValue: string;
begin
  Result := False;
  LpiFile := IncludeTrailingPathDelimiter(Config.qlLpiPath) + Config.qlLpiName;

  if not FileExists(LpiFile) then
    ExitWithError('LPI file not found: ' + LpiFile);

  try
    ReadXMLFile(XMLDoc, LpiFile);
    try
      // Navigate to VersionInfo node
      VersionInfoNode := XMLDoc.DocumentElement.FindNode('ProjectOptions');
      if not Assigned(VersionInfoNode) then
        raise Exception.Create('ProjectOptions node not found in LPI file');

      VersionInfoNode := VersionInfoNode.FindNode('VersionInfo');
      if not Assigned(VersionInfoNode) then
        raise Exception.Create('VersionInfo node not found in LPI file');

      // Extract version numbers
      VersionInfo.major := 0;
      VersionInfo.minor := 0;
      VersionInfo.patch := 0;
      VersionInfo.debug := False;
      VersionInfo.preReleaseOK := False;
      VersionInfo.description := '';
      VersionInfo.name := '';
      VersionInfo.version := '';

      // Parse child nodes
      for i := 0 to VersionInfoNode.ChildNodes.Count - 1 do
      begin
        case VersionInfoNode.ChildNodes[i].NodeName of
          'MajorVersionNr':
            VersionInfo.major := StrToIntDef(UTF8String(TDOMElement(VersionInfoNode.ChildNodes[i]).GetAttribute('Value')), 0);
          'MinorVersionNr':
            VersionInfo.minor := StrToIntDef(UTF8String(TDOMElement(VersionInfoNode.ChildNodes[i]).GetAttribute('Value')), 0);
          'RevisionNr':
            VersionInfo.patch := StrToIntDef(UTF8String(TDOMElement(VersionInfoNode.ChildNodes[i]).GetAttribute('Value')), 0);
          'Attributes':
            begin
              AttributesNode := VersionInfoNode.ChildNodes[i];
              AttrValue := UTF8String(TDOMElement(AttributesNode).GetAttribute('pvaDebug'));
              VersionInfo.debug := not (AttrValue = 'False');

              AttrValue := UTF8String(TDOMElement(AttributesNode).GetAttribute('pvaPreRelease'));
              VersionInfo.preReleaseOK := (AttrValue = 'True');
            end;
          'StringTable':
            begin
              StringTableNode := VersionInfoNode.ChildNodes[i];
              VersionInfo.description := UTF8String(TDOMElement(StringTableNode).GetAttribute('FileDescription'));
              VersionInfo.name := UTF8String(TDOMElement(StringTableNode).GetAttribute('ProductName'));
              VersionInfo.version := UTF8String(TDOMElement(StringTableNode).GetAttribute('ProductVersion'));
            end;
        end;
      end;

      Result := True;
    finally
      XMLDoc.Free;
    end;
  except
    on E: Exception do
      ExitWithError('Error reading LPI file: ' + E.Message);
  end;
end;

procedure CreateSemverFile;
var
  SemverFile: string;
  FileContent: string;
  OutputFile: TextFile;
  FileOpened: Boolean;
begin
  SemverFile := IncludeTrailingPathDelimiter(Config.qlDiagramPath) + Config.qlSemverName;

  FileContent := '!$semver = "' + IntToStr(VersionInfo.major) + '.' +
                 IntToStr(VersionInfo.minor) + '.' + IntToStr(VersionInfo.patch);

  if VersionInfo.preReleaseOK then
    FileContent := FileContent + '-' + Config.preRelease;

  FileContent := FileContent + '"';
  FileOpened := False;
  AssignFile(OutputFile, SemverFile);
  try
    try
      Rewrite(OutputFile);
      FileOpened := True;

      WriteLn(OutputFile, FileContent);
    finally
      if FileOpened then
      begin
        CloseFile(OutputFile);
      end;
    end;
  except
    on E: Exception do
      ExitWithError('Error creating semver file: ' + E.Message);
  end;
end;

procedure CreateVersionFile;
var
  VersionFile: string;
  JSONObject: TJSONObject;
  JSONArray: TJSONArray;
  OutputFile: TextFile;
  FileOpened: Boolean;
  i: Integer;
  SemverString: string;
begin
  VersionFile := IncludeTrailingPathDelimiter(Config.qlVersionPath) + Config.qlVersionName;

  // Build semver string
  SemverString := IntToStr(VersionInfo.major) + '.' + IntToStr(VersionInfo.minor) + '.' + IntToStr(VersionInfo.patch);
  if VersionInfo.preReleaseOK then
    SemverString := SemverString + '-' + Config.preRelease;

  try
    try
      JSONObject := TJSONObject.Create;

      // Add all fields
      JSONObject.Add('name', VersionInfo.name);
      JSONObject.Add('description', VersionInfo.description);

      // Add authors array
      JSONArray := TJSONArray.Create;
      for i := 0 to High(Config.authors) do
        JSONArray.Add(Config.authors[i]);
      JSONObject.Add('authors', JSONArray);

      JSONObject.Add('license', Config.license);
      JSONObject.Add('repository', Config.repository);
      JSONObject.Add('date', FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
      JSONObject.Add('version', VersionInfo.version);
      JSONObject.Add('major', VersionInfo.major);
      JSONObject.Add('minor', VersionInfo.minor);
      JSONObject.Add('patch', VersionInfo.patch);
      JSONObject.Add('debug', VersionInfo.debug);

      if VersionInfo.preReleaseOK then
        JSONObject.Add('pre-release', Config.preRelease)
      else
        JSONObject.Add('pre-release', TJSONNull.Create);

      JSONObject.Add('semver', SemverString);

      // Write to file
      FileOpened := False;
      AssignFile(OutputFile, VersionFile);
      Rewrite(OutputFile);
      FileOpened := True;

      WriteLn(OutputFile, JSONObject.FormatJSON);
    finally
      if FileOpened then
      begin
        CloseFile(OutputFile);
      end;
      JSONObject.Free;
    end;
  except
    on E: Exception do
      ExitWithError('Error creating version file: ' + E.Message);
  end;
end;

begin
  WriteLn('');
  WriteLn('qlsemver - Semantic Version Generator');
  WriteLn('====================================');

  try
    // Load configuration
    if not LoadConfig then
      ExitWithError('Failed to load configuration');

    WriteLn('Configuration loaded successfully');

    // Load LPI file
    if not LoadLpiFile then
      ExitWithError('Failed to load LPI file');

    WriteLn('LPI file parsed successfully');
    WriteLn('Version: ', VersionInfo.major, '.', VersionInfo.minor, '.', VersionInfo.patch);

    // Create semver file
    CreateSemverFile;
    WriteLn('Semver file created: ', Config.qlDiagramPath, PathDelim, Config.qlSemverName);

    // Create version file
    CreateVersionFile;
    WriteLn('Version file created: ', Config.qlVersionPath, PathDelim, Config.qlVersionName);

    WriteLn('Process completed successfully');
    WriteLn('');

  except
    on E: Exception do
      ExitWithError('Unexpected error: ' + E.Message);
  end;
end.
