require 'tk'
require 'tkextlib/tile'

root = TkRoot.new {title "Advance Database Demo"}
content = Tk::Tile::Frame.new(root) {padding "12 12 12 12"}.grid( :sticky => 'nsew')
TkGrid.columnconfigure root, 0, :weight => 1; TkGrid.rowconfigure root, 0, :weight => 1

$feet = TkVariable.new; $meters = TkVariable.new
f = Tk::Tile::Entry.new(content) {width 7; textvariable $feet}.grid( :column => 50, :row => 50, :sticky => 'we' )
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 100, :row => 100, :sticky => 'we');
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 21, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 2, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 3, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 4, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 5, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 6, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 7, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 8, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 9, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 10, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 11, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 12, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 13, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 14, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 15, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 16, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 17, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 18, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 19, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Fail'; command {calculate}}.grid( :column => 4, :row => 20, :sticky => 'w')


Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 21, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 2, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 3, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 4, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 5, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 6, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 7, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 8, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 9, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 10, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 11, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 12, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 13, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 14, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 15, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 16, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 17, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 18, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 19, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Recover'; command {calculate}}.grid( :column => 5, :row => 20, :sticky => 'w')



Tk::Tile::Label.new(content) {text 'Sites'}.grid( :column => 1, :row => 1, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Vars'}.grid( :column => 2, :row => 1, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Vals'}.grid( :column => 3, :row => 1, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Fail'}.grid( :column => 4, :row => 1, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Recover'}.grid( :column => 5, :row => 1, :sticky => 'w')

Tk::Tile::Label.new(content) {text 'Site1'}.grid( :column => 1, :row => 2, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site2'}.grid( :column => 1, :row => 3, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site3'}.grid( :column => 1, :row => 4, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site4'}.grid( :column => 1, :row => 5, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site5'}.grid( :column => 1, :row => 6, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site6'}.grid( :column => 1, :row => 7, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site7'}.grid( :column => 1, :row => 8, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site8'}.grid( :column => 1, :row => 9, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site9'}.grid( :column => 1, :row => 10, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site10'}.grid( :column => 1, :row => 11, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site11'}.grid( :column => 1, :row => 12, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site12'}.grid( :column => 1, :row => 13, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site13'}.grid( :column => 1, :row => 14, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site14'}.grid( :column => 1, :row => 15, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site15'}.grid( :column => 1, :row => 16, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site16'}.grid( :column => 1, :row => 17, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site17'}.grid( :column => 1, :row => 18, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site18'}.grid( :column => 1, :row => 19, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site19'}.grid( :column => 1, :row => 20, :sticky => 'w')
Tk::Tile::Label.new(content) {text 'Site20'}.grid( :column => 1, :row => 21, :sticky => 'w')



Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 2, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 3, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 4, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 5, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 6, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 7, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 8, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 9, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 10, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 11, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 12, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 13, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 14, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 15, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 16, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 17, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 18, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 19, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 20, :sticky => 'we');
Tk::Tile::Label.new(content) {textvariable $meters}.grid( :column => 3, :row => 21, :sticky => 'we');

$countryvar = TkVariable.new
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 2, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 3, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 4, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 5, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 6, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 7, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 8, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 9, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 10, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 11, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 12, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 13, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 14, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 15, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 16, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 17, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 18, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 19, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 20, :sticky => 'we')
country = Tk::Tile::Combobox.new(content) { textvariable $countryvar }.grid( :column => 2, :row => 21, :sticky => 'we')

TkWinfo.children(content).each {|w| TkGrid.configure w, :padx => 5, :pady => 5}
f.focus
root.bind("Return") {calculate}

def calculate
  begin
     $meters.value = (0.3048*$feet*10000.0).round()/10000.0
  rescue
     $meters.value = ''
  end
end

Tk.mainloop
