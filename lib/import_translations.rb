require 'csv'

class GlobalizeMigration < ActiveRecord::Migration

  def self.up
    # add in defaults
    load_from_csv("globalize_countries", country_data)
    load_from_csv("globalize_languages", language_data)
    load_from_csv("globalize_translations", translation_data)
  end

  def self.load_from_csv(table_name, data)
    column_clause = nil
    is_header = false
    cnx = ActiveRecord::Base.connection
    ActiveRecord::Base.silence do
      reader = CSV::Reader.create(data) 
      
      columns = reader.shift.map {|column_name| cnx.quote_column_name(column_name) }
      column_clause = columns.join(', ')

      reader.each do |row|
        next if row.first.nil? # skip blank lines
        raise "No table name defined" if !table_name
        raise "No header defined" if !column_clause
        values_clause = row.map {|v| cnx.quote(v).gsub('\\n', "\n").gsub('\\r', "\r") }.join(', ')
        sql = "INSERT INTO #{table_name} (#{column_clause}) VALUES (#{values_clause})"
        cnx.insert(sql) 
      end
    end
  end

  def self.country_data
    <<END_OF_DATA
"id","code","english_name","date_format","currency_format","currency_code","thousands_sep","decimal_sep","currency_decimal_sep","number_grouping_scheme"
1,"BR","Brazil",,"R$%n","BRR",".",",",",","western"
2,"US","United States of America",,,"USD",",",".",".","western"
END_OF_DATA
  end

  def self.language_data
    <<END_OF_DATA
"id","iso_639_1","iso_639_2","iso_639_3","rfc_3066","english_name","english_name_locale","english_name_modifier","native_name","native_name_locale","native_name_modifier","macro_language","direction","pluralization","scope"
1,"en","eng","eng",,"English",,,,,,0,"ltr","c == 1 ? 1 : 2","L"
2,"pt","por","por",,"Portuguese",,,"português",,,0,"ltr","c == 1 ? 1 : 2","L"
END_OF_DATA
  end

  def self.translation_data
    <<END_OF_DATA
"id","type","tr_key","table_name","item_id","facet","language_id","text","pluralization_index"
1,"ViewTranslation","Sunday [weekday]","",,"",1,"Sunday",1
2,"ViewTranslation","Monday [weekday]","",,"",1,"Monday",1
3,"ViewTranslation","Tuesday [weekday]","",,"",1,"Tuesday",1
4,"ViewTranslation","Wednesday [weekday]","",,"",1,"Wednesday",1
5,"ViewTranslation","Thursday [weekday]","",,"",1,"Thursday",1
6,"ViewTranslation","Friday [weekday]","",,"",1,"Friday",1
7,"ViewTranslation","Saturday [weekday]","",,"",1,"Saturday",1
8,"ViewTranslation","Sun [abbreviated weekday]","",,"",1,"Sun",1
9,"ViewTranslation","Mon [abbreviated weekday]","",,"",1,"Mon",1
10,"ViewTranslation","Tue [abbreviated weekday]","",,"",1,"Tue",1
11,"ViewTranslation","Wed [abbreviated weekday]","",,"",1,"Wed",1
12,"ViewTranslation","Thu [abbreviated weekday]","",,"",1,"Thu",1
13,"ViewTranslation","Fri [abbreviated weekday]","",,"",1,"Fri",1
14,"ViewTranslation","Sat [abbreviated weekday]","",,"",1,"Sat",1
15,"ViewTranslation","January [month]","",,"",1,"January",1
16,"ViewTranslation","February [month]","",,"",1,"February",1
17,"ViewTranslation","March [month]","",,"",1,"March",1
18,"ViewTranslation","April [month]","",,"",1,"April",1
19,"ViewTranslation","May [month]","",,"",1,"May",1
20,"ViewTranslation","June [month]","",,"",1,"June",1
21,"ViewTranslation","July [month]","",,"",1,"July",1
22,"ViewTranslation","August [month]","",,"",1,"August",1
23,"ViewTranslation","September [month]","",,"",1,"September",1
24,"ViewTranslation","October [month]","",,"",1,"October",1
25,"ViewTranslation","November [month]","",,"",1,"November",1
26,"ViewTranslation","December [month]","",,"",1,"December",1
27,"ViewTranslation","Jan [abbreviated month]","",,"",1,"Jan",1
28,"ViewTranslation","Feb [abbreviated month]","",,"",1,"Feb",1
29,"ViewTranslation","Mar [abbreviated month]","",,"",1,"Mar",1
30,"ViewTranslation","Apr [abbreviated month]","",,"",1,"Apr",1
31,"ViewTranslation","May [abbreviated month]","",,"",1,"May",1
32,"ViewTranslation","Jun [abbreviated month]","",,"",1,"Jun",1
33,"ViewTranslation","Jul [abbreviated month]","",,"",1,"Jul",1
34,"ViewTranslation","Aug [abbreviated month]","",,"",1,"Aug",1
35,"ViewTranslation","Sep [abbreviated month]","",,"",1,"Sep",1
36,"ViewTranslation","Oct [abbreviated month]","",,"",1,"Oct",1
37,"ViewTranslation","Nov [abbreviated month]","",,"",1,"Nov",1
38,"ViewTranslation","Dec [abbreviated month]","",,"",1,"Dec",1
5967,"ViewTranslation","Sunday [weekday]","",,"",2,"Domingo",1
5968,"ViewTranslation","Monday [weekday]","",,"",2,"Segunda",1
5969,"ViewTranslation","Tuesday [weekday]","",,"",2,"Terça",1
5970,"ViewTranslation","Wednesday [weekday]","",,"",2,"Quarta",1
5971,"ViewTranslation","Thursday [weekday]","",,"",2,"Quinta",1
5972,"ViewTranslation","Friday [weekday]","",,"",2,"Sexta",1
5973,"ViewTranslation","Saturday [weekday]","",,"",2,"Sábado",1
5974,"ViewTranslation","Sun [abbreviated weekday]","",,"",2,"Dom",1
5975,"ViewTranslation","Mon [abbreviated weekday]","",,"",2,"Seg",1
5976,"ViewTranslation","Tue [abbreviated weekday]","",,"",2,"Ter",1
5977,"ViewTranslation","Wed [abbreviated weekday]","",,"",2,"Qua",1
5978,"ViewTranslation","Thu [abbreviated weekday]","",,"",2,"Qui",1
5979,"ViewTranslation","Fri [abbreviated weekday]","",,"",2,"Sex",1
5980,"ViewTranslation","Sat [abbreviated weekday]","",,"",2,"Sáb",1
5981,"ViewTranslation","January [month]","",,"",2,"Janeiro",1
5982,"ViewTranslation","February [month]","",,"",2,"Fevereiro",1
5983,"ViewTranslation","March [month]","",,"",2,"Março",1
5984,"ViewTranslation","April [month]","",,"",2,"Abril",1
5985,"ViewTranslation","May [month]","",,"",2,"Maio",1
5986,"ViewTranslation","June [month]","",,"",2,"Junho",1
5987,"ViewTranslation","July [month]","",,"",2,"Julho",1
5988,"ViewTranslation","August [month]","",,"",2,"Agosto",1
5989,"ViewTranslation","September [month]","",,"",2,"Setembro",1
5990,"ViewTranslation","October [month]","",,"",2,"Outubro",1
5991,"ViewTranslation","November [month]","",,"",2,"Novembro",1
5992,"ViewTranslation","December [month]","",,"",2,"Dezembro",1
5993,"ViewTranslation","Jan [abbreviated month]","",,"",2,"Jan",1
5994,"ViewTranslation","Feb [abbreviated month]","",,"",2,"Fev",1
5995,"ViewTranslation","Mar [abbreviated month]","",,"",2,"Mar",1
5996,"ViewTranslation","Apr [abbreviated month]","",,"",2,"Abr",1
5997,"ViewTranslation","May [abbreviated month]","",,"",2,"Mai",1
5998,"ViewTranslation","Jun [abbreviated month]","",,"",2,"Jun",1
5999,"ViewTranslation","Jul [abbreviated month]","",,"",2,"Jul",1
6000,"ViewTranslation","Aug [abbreviated month]","",,"",2,"Ago",1
6001,"ViewTranslation","Sep [abbreviated month]","",,"",2,"Set",1
6002,"ViewTranslation","Oct [abbreviated month]","",,"",2,"Out",1
6003,"ViewTranslation","Nov [abbreviated month]","",,"",2,"Nov",1
6004,"ViewTranslation","Dec [abbreviated month]","",,"",2,"Dez",1
END_OF_DATA
  end  
end

Locale.set_base_language('en-US')

begin
  Locale.set_translation('test', Language.pick('pt-BR'), 'teste')
rescue
  GlobalizeMigration.up
end

translation_dir = File.expand_path(__FILE__ + '/../../db/translation')
Dir.foreach(translation_dir) do |file|
  if (file[0, 1] != '.') then
    puts "Reading translation file #{file}"
    lang_code = file[0, file.length - 3]
    language = Language.pick(lang_code)
    contents = File.read(File.join(translation_dir, file))
    translations = eval contents
    translations.each do |key, value|
      Locale.set_translation(key, language, value)
    end
  end
end