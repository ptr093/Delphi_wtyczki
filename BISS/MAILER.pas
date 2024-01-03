 //AutoGenPdfWyslijEmail
{$ADDTYPE TstStringList}
{$ADDTYPE TReportParam}

function WyslijMailDll(KatalogTemp: PChar; EmailList: PChar; ReplyTo: PChar): Integer;
         external 'WyslijMailDll@D:\STREAM\PLUGINS\mailer\SendEmailDll.dll stdcall';

var
  LogStringList: TStringList;
  PlikLog: string;
  idNagl: integer;

 const
  cIdRaportRbListaPozycji = 10058;

const
  cKatalogLog = 'D:\STREAM\PLUGINS\MAILER\log\';
  cStopkaHtml = 'D:\STREAM\PLUGINS\MAILER\stopka.html';
  cFolderDrukuj='C:\Users\streamsoft3\Desktop\test\';

const
  cPathDelimeter = '\';
  cPrefiksNazwyPliku = '';
  cSufiksOryginal = '_Oryginał';



const
  cLineBreak = #13#10;

function PobNazwePlikuLog: string;
var
  vData: string;
begin
  DateTimeToString(vData, 'yyyy-MM-dd_hhmmss', Now);
  Result := 'Log_' + vData + '.txt';
end;

procedure PrzygotujLog;
begin
  if (LogStringList <> nil) then Exit;

  LogStringList := TStringList.Create;

  PlikLog := PobNazwePlikuLog;

  LogStringList.SaveToFile(cKatalogLog + PlikLog);
end;

procedure DodajDoLogu(const ATekst: string);
begin
  if (LogStringList = nil) then Exit;

  LogStringList.Append(DateTimeToStr(Now) + ': ' + ATekst);
  LogStringList.SaveToFile(cKatalogLog + PlikLog);
end;

function PobNrDok(const AIdNagl: string): string;
var
  vSql: string;
begin
  vSql :='select N.NRDOKWEW'
      +' from NAGL N'
      +' join DEFDOK DD on N.ID_DEFDOK = DD.ID_DEFDOK'
      +' join WYSTCECHNAGL WCN on N.ID_NAGL = WCN.ID_NAGL and WCN.ID_CECHADOKK = 10074'
      +' join KONTRAH K on N.ID_KONTRAH = K.ID_KONTRAH'
      +' join WYSTCECHYKONTRAH WCK on N.ID_KONTRAH = WCK.ID_KONTRAH and WCK.ID_CECHA = 10286'
      +' join POZ P on N.ID_NAGL = P.ID_NAGL'
      +' join POZZAMWSP PZW on P.ID_POZ = PZW.ID_POZ'
      +' where DD.ID_SPISDOK = 600 and'
      +' upper(WCN.WARTOSC) = '+  QuotedStr('TAK')
      +' and cast(PZW.TERMINDOST as date) - 2 = current_date'
      +' and n.id_nagl ='+ AIdNagl;



  Result := Trim(GetFromQuerySQL(vSql, 0));
end;

function PobSkrotDefDok(const AIdNagl: string): string;
var
  vSql: string;
begin
  vSql := 'select dd.skrotdefdok'
       + ' from nagl n'
       + ' join defdok dd on n.id_defdok = dd.id_defdok'
       + ' where n.id_nagl = ' + AIdNagl;

  Result := Trim(GetFromQuerySQL(vSql, 0));
end;

function PobUtworzFolder(const AIdNagl: string): string;
var
  vFolder: string;
  vSkrDok: string;
  vData: string;
begin
  vFolder := cFolderDrukuj;
  if not DirectoryExists(vFolder) then
    CreateDir(vFolder);

  vSkrDok := PobSkrotDefDok(AIdNagl);

  vFolder := vFolder + vSkrDok;
  if not DirectoryExists(vFolder) then
    CreateDir(vFolder);

  DateTimeToString(vData, 'yyyy-MM-dd', Now);
  Zastap('-', cPathDelimeter, vData);

  vFolder := vFolder + cPathDelimeter + Copy(vData, 1, 4);
  if not DirectoryExists(vFolder) then
    CreateDir(vFolder);

  vFolder := vFolder + cPathDelimeter + Copy(vData, 6, 2);
  if not DirectoryExists(vFolder) then
    CreateDir(vFolder);

  vFolder := vFolder + cPathDelimeter + Copy(vData, 9, 2);
  if not DirectoryExists(vFolder) then
    CreateDir(vFolder);

  Result := cFolderDrukuj + vSkrDok + cPathDelimeter + vData + cPathDelimeter;
end;

function PobNazwePliku(const AIdNagl: string): string;
var
  vNrDok: string;
  vData: string;
begin
  vNrDok := PobNrDok(AIdNagl);
  Zastap('/', '_', vNrDok);

  DateTimeToString(vData, 'yyyy-MM-dd_hhmmss', Now);

  Result := Trim(cPrefiksNazwyPliku + ' ' + vNrDok + ' ' + vData);
end;

function PobWartoscDokumentu(const AIdNagl: string): string;
var
  vSql: string;
begin
  vSql := 'select zv.netto'
       + ' from nagl n'
       + ' left outer join zestawienievat zv on (n.id_nagl = zv.id_nagl) and (zv.klu_id_stawkavat = 0) and (zv.typpodsumow = 0) and (zv.ewivat7 = 0)'
       + ' where n.id_nagl = ' + AIdNagl;

  Result := Trim(GetFromQuerySQL(vSql, 0));
end;

function PobTerminPlatnosciDokumentu(const AIdNagl: string): string;
var
  vSql: string;
begin
  vSql := 'select cast(n.termplatn as date)'
       + ' from nagl n'
       + ' where n.id_nagl = ' + AIdNagl;

  Result := Trim(GetFromQuerySQL(vSql, 0));
end;


function PobierzEmailList(const AIdNagl: string): string;
var
  vSql: string;
begin
     vSql :='select K.EMAIL'
      +' from NAGL N'
      +' join DEFDOK DD on N.ID_DEFDOK = DD.ID_DEFDOK'
      +' join WYSTCECHNAGL WCN on N.ID_NAGL = WCN.ID_NAGL and WCN.ID_CECHADOKK = 10074'
      +' join KONTRAH K on N.ID_KONTRAH = K.ID_KONTRAH'
      +' join WYSTCECHYKONTRAH WCK on N.ID_KONTRAH = WCK.ID_KONTRAH and WCK.ID_CECHA = 10286'
      +' join POZ P on N.ID_NAGL = P.ID_NAGL'
      +' join POZZAMWSP PZW on P.ID_POZ = PZW.ID_POZ'
      +' where DD.ID_SPISDOK = 600 and'
      +' upper(WCN.WARTOSC) = '+  QuotedStr('TAK')
      +' and cast(PZW.TERMINDOST as date) - 2 = current_date'
      +' and n.id_nagl ='+ AIdNagl;

  Result := Trim(GetFromQuerySQL(vSql, 0));
end;

function PobStopke: string;
var
  vSL: TstStringList;
begin
  Result := '';
  if not FileExists(cStopkaHtml) then Exit;

  vSL := TstStringList.Create;
  try
    vSL.LoadFromFile(cStopkaHtml);
    Result := vSL.Text;
  finally
    vSL.Free;
  end;
end;

procedure WyslijMail(const AKatalogTemp, AEmailList, AReplayTo, ASubject, ABody: string);
var
  vSL: TstStringList;
begin
  vSL := TstStringList.Create;
  try
    vSL.Clear;
    vSL.Add(ASubject);
    vSL.SaveToFile(AKatalogTemp + '\'+ '$email_subject$');

    vSL.Clear;
    vSL.Add(ABody);
    vSL.SaveToFile(AKatalogTemp + '\'+ '$email_body$');
  finally
    vSL.Free;
  end;

  WyslijMailDll(PChar(AKatalogTemp), PChar(AEmailList), PChar(AReplayTo));
end;




procedure SetParams(AParams: TObjectList);
var
  p: TReportParam;
  i: Integer;
begin
  for i := 0 to AParams.Count - 1 do
  begin
    p := TReportParam(AParams.Items[i]);
    if (p.Nazwa = 'ID_NAGL') then
    begin
      p.Wartosc := idNagl;
    end;
  end;
end;



procedure WydrukujDoPdfWyslijEmail(const AIdNagl: string);
var
  vFolder: string;
  vNazwaPliku: string;
  vGuid: string;
  vHResult: HResult;
  vUid: TGuid;
  vEmailList: string;
  vReplayTo: string;
  vKatalogTemp: string;
  vNrDok: string;
  vData: string;
  vSubject: string;
  vBody: string;
  vBodyBezStopki: string;
  vSL: TstStringList;
begin
  DodajDoLogu('Dokument (id_nagl): ' + AIdNagl);

  vNrDok := PobNrDok(AIdNagl);

  DodajDoLogu('Dokument: ' + vNrDok);



  vEmailList := PobierzEmailList(AIdNagl);
  if (vEmailList = '') then
  begin
    DodajDoLogu('Nieokreślony adres email.');
    Exit;
  end;



  vNazwaPliku := PobNazwePliku(AIdNagl);
  DodajDoLogu('Nazwa pliku: ' + vNazwaPliku + '.pdf');

  DodajDoLogu('Adres email: ' + vEmailList);


  vSubject := Trim('Potwierdzenie zamówienia nr  ' + vNrDok);

  DodajDoLogu('Temat maila: ' + cLineBreak + vSubject);

  vSL := TstStringList.Create;
  try
    vSL.Clear;
    vSL.Add('<p>Dzień Dobry,</p>');
    vSL.Add('<p>W załączniku znajduje się zamówienie w formacie pdf /p>');
    vBodyBezStopki := vSL.Text;
    vSL.Add(PobStopke);
    vBody := vSL.Text;
  finally
    vSL.Free;
  end;

  DodajDoLogu('Treść maila (bez stopki): ' + cLineBreak + vBodyBezStopki);

  vFolder := PobUtworzFolder(AIdNagl);

  vGuid := '';

  vHResult := CreateGuid(vUid);
  if (vHResult = S_OK) then
    vGuid := GuidToString(vUid);

  if (vGuid = '') then
  begin
    DodajDoLogu('Błąd przy generowaniu nazwy katalogu.');
    Exit;
  end;

  vKatalogTemp := GetTempDir + vGuid;
  if not DirectoryExists(vKatalogTemp) then
    CreateDir(vKatalogTemp);

  DodajDoLogu('Wydruk i zapis dokumentu do pliku:');
  DodajDoLogu(vFolder + vNazwaPliku + cSufiksOryginal + '.pdf');

  ZestawienieDefOnParamsExtended(cIdRaportRbListaPozycji, @SetParams, False, False, 'PDF:' + cFolderDrukuj + '\' + vNazwaPliku + '.pdf');

  DodajDoLogu('Wykonanie funkcji PrintStandardDokGM: True');

 if not FileExists(cFolderDrukuj + vNazwaPliku  + '.pdf') then
  begin
    DodajDoLogu('Nie udało się poprawnie wydrukować i zapisać dokumentu do pliku - brak pliku.');
    Exit;
  end;


  DodajDoLogu('Zapis informacji o wygenerowaniu pliku.');

  DodajDoLogu('Kopiowanie pliku: ' + vNazwaPliku + cSufiksOryginal + '.pdf');
  if not CopyFileCheckAll(cFolderDrukuj + vNazwaPliku  + '.pdf',
    vKatalogTemp + cPathDelimeter + vNazwaPliku + cSufiksOryginal + '.pdf', False) then
  begin
    DodajDoLogu('Błąd przy kopiowaniu pliku.');
    Exit;
  end;
  DodajDoLogu('Skopiowano plik.');

  DodajDoLogu('Wysyłanie maila.');

  vReplayTo := '';

  WyslijMail(vKatalogTemp + '\', vEmailList, vReplayTo, vSubject, vBody);

  DodajDoLogu('Wysłano maila.');

  DodajDoLogu('Zapisanie informacji o wysłaniu maila (cechy).');

  DateTimeToString(vData, 'yyyy-MM-dd hh:mm:ss', Now);


end;

procedure Wykonaj;
var
  vLog: string;
  vSql: string;
  vDataSource: TDataSource;
begin
  vLog := 'Uruchomiono proces generowania plików pdf i wysyłki maili:' + cLineBreak
           + 'Data wykonania: ' + DateTimeToStr(Now) + cLineBreak
           + 'Użytkownik: ' + GetUser + cLineBreak
           + 'Stanowisko: ' + GetWorkStation;
  DodajDoLogu(vLog);

  try

      vSql :='select N.ID_NAGL'
      +' from NAGL N'
      +' join DEFDOK DD on N.ID_DEFDOK = DD.ID_DEFDOK'
      +' join WYSTCECHNAGL WCN on N.ID_NAGL = WCN.ID_NAGL and WCN.ID_CECHADOKK = 10074'
      +' join KONTRAH K on N.ID_KONTRAH = K.ID_KONTRAH'
      +' join WYSTCECHYKONTRAH WCK on N.ID_KONTRAH = WCK.ID_KONTRAH and WCK.ID_CECHA = 10286'
      +' join POZ P on N.ID_NAGL = P.ID_NAGL'
      +' join POZZAMWSP PZW on P.ID_POZ = PZW.ID_POZ'
      +' where DD.ID_SPISDOK = 600 and'
      +' upper(WCN.WARTOSC) = '+  QuotedStr('TAK')
      +' and cast(PZW.TERMINDOST as date) - 2 = current_date';

      vDataSource := OpenQuerySQL(vSql, 0);
      try
        vDataSource.DataSet.First;
        while not vDataSource.DataSet.Eof do
        begin
          idNagl:= strToInt(vDataSource.DataSet.FieldByName('id_nagl').AsString);
          WydrukujDoPdfWyslijEmail(vDataSource.DataSet.FieldByName('id_nagl').AsString);
          DodajDoLogu('Wygenerowano i wysłano maila dla  (id_nagl): ' + vDataSource.DataSet.FieldByName('id_nagl').AsString);
          vDataSource.DataSet.Next;
        end;
      finally
        CloseQuerySQL(vDataSource);
      end;
  finally
    DodajDoLogu('Zakończono proces generowania plików pdf i wysyłki maili.');
  end;
end;

begin
  try
    PrzygotujLog;
    Wykonaj;
  finally
    if (LogStringList <> nil) then
      LogStringList.Free;
    LogStringList := nil;
  end;
end.