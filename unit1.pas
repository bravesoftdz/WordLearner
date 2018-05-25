unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls;

const
  MaxWordListCount = 30;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    ScrollBar1: TScrollBar;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1SelectionChange(Sender: TObject; User: boolean);
    procedure ListBox2SelectionChange(Sender: TObject; User: boolean);

  private
    { private declarations }
  public
    { public declarations }
  end;

type
  Word_type = record
    Word1, Word2: string;
    Score: byte;
  end;

var
  Form1: TForm1;
  Words: array[1..10000] of Word_type;
  nWords: integer;

  Wordlist1, Wordlist2: array[1..MaxWordListCount] of integer;

  WordListCount: byte;

  Word1, Word2: byte;

  File1: Text;
  File2: file of byte;

implementation

procedure LoadData;
var
  i: integer;
begin
  Randomize;
  AssignFile(File1, 'words.txt');
  Reset(File1);
  nWords := 0;
  repeat
    Inc(nWords);
    ReadLn(File1, Words[nWords].Word1);
    ReadLn(File1, Words[nWords].Word2);
  until EOF(File1);
  CloseFile(File1);

  Form1.Label4.Caption := 'Number of Words = ' + IntToStr(nWords);

  AssignFile(File2, 'words.sco');
  {$i-}
  Reset(File2);
  if IOResult > 0 then
    Rewrite(File2);
  {$i+}
  for i := 1 to nWords do
    if (not EOF(File2)) then
      Read(File2, Words[i].Score)
    else
      Words[i].Score := 1;
  CloseFile(File2);
end;

procedure SaveData;
var
  i: integer;
begin
  AssignFile(File2, 'words.sco');
  Rewrite(File2);
  for i := 1 to nWords do
    Write(File2, Words[i].Score);
  CloseFile(File2);
end;


procedure GenerateList;
var
  i, j, k: integer;
  WordFound: boolean;
begin
  WordListCount := Form1.ScrollBar1.Position;

  for j := 1 to WordListCount do
    repeat
      WordFound := false;
      i := Trunc(Random * (nWords)) + 1;
      if Random < (1 / Words[i].Score) then
      begin
        Wordlist1[j] := i;
        WordFound := true;
      end;
      if j > 1 then
        for k := 1 to j - 1 do
          if i = Wordlist1[k] then
            WordFound := false;
      if (Words[i].Score = 1) and (Random > 0.01) then
        WordFound := false;
    until WordFound;

  for j := 1 to WordListCount do
    repeat
      WordFound := true;
      i := Wordlist1[Trunc(Random * (WordListCount)) + 1];
      if j > 1 then
        for k := 1 to j - 1 do
          if i = Wordlist2[k] then
            WordFound := false;
      if WordFound then
        Wordlist2[j] := i;
    until WordFound;

  Form1.ListBox1.Clear;
  Form1.ListBox2.Clear;
  for j := 1 to WordListCount do
  begin
    Form1.ListBox1.Items.Add(Words[Wordlist1[j]].Word1);
    Form1.ListBox2.Items.Add(Words[Wordlist2[j]].Word2);
  end;

  Form1.ListBox1.Enabled := true;
  Form1.ListBox2.Enabled := false;

end;

{ TForm1 }


procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveData;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  GenerateList;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  LoadData;
  GenerateList;
end;

procedure TForm1.ListBox1SelectionChange(Sender: TObject; User: boolean);
var
  j: byte;
begin
  ListBox1.Enabled := false;
  ListBox2.Enabled := true;
  for j := 1 to ListBox1.Items.Count do
    if ListBox1.Selected[j - 1] then
      Word1 := j;
  Label2.Caption := IntToStr(Words[Wordlist1[Word1]].Score - 1);
  Label1.Visible := true;
  Label2.Visible := true;
end;

procedure TForm1.ListBox2SelectionChange(Sender: TObject; User: boolean);
var
  j: byte;
begin
  for j := 1 to ListBox2.Items.Count do
    if ListBox2.Selected[j - 1] then
      Word2 := j;
  if Wordlist1[Word1] = Wordlist2[Word2] then
  begin
    Inc(Words[Wordlist1[Word1]].Score);
    if Words[Wordlist1[Word1]].Score > 200 then
      Words[Wordlist1[Word1]].Score := 200;
    if Word1 < ListBox1.Items.Count then
      for j := Word1 to ListBox1.Items.Count - 1 do
        Wordlist1[j] := Wordlist1[j + 1];
    if Word2 < ListBox2.Items.Count then
      for j := Word2 to ListBox2.Items.Count - 1 do
        Wordlist2[j] := Wordlist2[j + 1];
    ListBox1.Items.Delete(Word1 - 1);
    ListBox2.Items.Delete(Word2 - 1);
  end else
  begin
    Words[Wordlist1[Word1]].Score := Words[Wordlist1[Word1]].Score div 2;
    if Words[Wordlist1[Word1]].Score = 0 then
      Words[Wordlist1[Word1]].Score := 1;
    Words[Wordlist2[Word2]].Score := Words[Wordlist2[Word2]].Score div 2;
    if Words[Wordlist2[Word2]].Score = 0 then
      Words[Wordlist2[Word2]].Score := 1;
    ListBox1.Selected[Word1 - 1] := false;
    ListBox2.Selected[Word2 - 1] := false;
  end;
  if ListBox1.Items.Count = 0 then
  begin
    SaveData;
    GenerateList;
  end;
  ListBox1.Enabled := true;
  ListBox2.Enabled := false;
  Label1.Visible := false;
  Label2.Visible := false;
end;



initialization
  {$I unit1.lrs}

end.
