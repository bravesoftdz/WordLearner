unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls;

const maxwordlistcount=30;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
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

type word_type = record
 word1,word2:string;
 score:byte;
end;

var
  Form1: TForm1;
  words:array[1..10000] of word_type;
  nwords:integer;

  wordlist1,wordlist2:array[1..maxwordlistcount] of integer;
  
  wordlistcount:byte;
  
  word1,word2:byte;

  file1:Text;
  file2:file of byte;

implementation

Procedure loaddata;
var i:integer;
begin
  randomize;
  AssignFile(file1,'words.txt');
  {$i-}
  reset(file1);
  if ioresult<>0 then rewrite(file2);
  {$i+}
  nwords:=0;
  repeat
    inc(nwords);
    readln(file1,words[nwords].word1);
    readln(file1,words[nwords].word2);
  until eof(file1);
  closefile(file1);
  
  form1.label4.caption:='Number of words = '+inttostr(nwords);

  AssignFile(file2,'words.sco');
  {$i-}
  reset(file2);
  if IOresult>0 then rewrite(file2);
  {$i+}
  for i:=1 to nwords do if (not eof(file2)) then read(file2,words[i].score) else words[i].score:=1;
  closefile(file2);
end;

Procedure savedata;
var i:integer;
begin
  AssignFile(file2,'words.sco');
  rewrite(file2);
  for i:=1 to nwords do write(file2,words[i].score);
  closefile(file2);
end;


Procedure generatelist;
var i,j,k:integer;
    wordfound:boolean;
begin
  wordlistcount:=form1.ScrollBar1.position;

  for j:=1 to wordlistcount do repeat
    wordfound:=false;
    i:=trunc(random*(nwords))+1;
    if random<(1/words[i].score) then begin
      wordlist1[j]:=i;
      wordfound:=true;
    end;
    if j>1 then for k:=1 to j-1 do if i=wordlist1[k] then wordfound:=false;
    if (words[i].score=1) and (random>0.01) then wordfound:=false;
  until wordfound;

  for j:=1 to wordlistcount do repeat
    wordfound:=true;
    i:=wordlist1[trunc(random*(wordlistcount))+1];
    if j>1 then for k:=1 to j-1 do if i=wordlist2[k] then wordfound:=false;
    if wordfound then wordlist2[j]:=i;
  until wordfound;

  form1.listbox1.clear;form1.listbox2.clear;
  for j:=1 to wordlistcount do begin
    form1.listbox1.items.Add(words[wordlist1[j]].word1{ +'  ('+inttostr(words[wordlist1[j]].score-1)+')'});
    form1.listbox2.items.Add(words[wordlist2[j]].word2);
  end;

  form1.listbox1.enabled:=true;
  form1.listbox2.enabled:=false;

end;

{ TForm1 }


procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  savedata;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  generatelist;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  loaddata;
  generatelist;
end;

procedure TForm1.ListBox1SelectionChange(Sender: TObject; User: boolean);
var j:byte;
begin
  listbox1.enabled:=false;
  listbox2.enabled:=true;
  for j:=1 to listbox1.items.count do if listbox1.Selected[j-1] then word1:=j;
  label2.Caption:=inttostr(words[wordlist1[word1]].score-1);
  label1.Visible:=true;label2.visible:=true;
end;

procedure TForm1.ListBox2SelectionChange(Sender: TObject; User: boolean);
var j:byte;
begin
  for j:=1 to listbox2.items.count do if listbox2.Selected[j-1] then word2:=j;
  if wordlist1[word1]=wordlist2[word2] then begin
    inc(words[wordlist1[word1]].score);
    if words[wordlist1[word1]].score>200 then words[wordlist1[word1]].score:=200;
    if word1<listbox1.items.count then for j:=word1 to listbox1.items.count-1 do wordlist1[j]:=wordlist1[j+1];
    if word2<listbox2.items.count then for j:=word2 to listbox2.items.count-1 do wordlist2[j]:=wordlist2[j+1];
    listbox1.Items.Delete(word1-1);
    listbox2.Items.Delete(word2-1);
  end else begin
    words[wordlist1[word1]].score:=words[wordlist1[word1]].score div 2; if words[wordlist1[word1]].score=0 then words[wordlist1[word1]].score:=1;
    words[wordlist2[word2]].score:=words[wordlist2[word2]].score div 2; if words[wordlist2[word2]].score=0 then words[wordlist2[word2]].score:=1;
    listbox1.Selected[word1-1]:=false;
    listbox2.Selected[word2-1]:=false;
  end;
  if listbox1.items.count=0 then begin savedata; generatelist; end;
  listbox1.enabled:=true;
  listbox2.enabled:=false;
  label1.Visible:=false;label2.visible:=false;
end;



initialization
  {$I unit1.lrs}

end.
