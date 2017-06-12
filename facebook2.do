
//Importar delimitado gerado pelo R
import delimited facebook.csv, delimiter(";") 

//Gerar variável de data
destring month, replace
gen month2 = substr(month, 6, 2)
destring month2, replace
gen year = substr(month, 1, 4)
destring year, replace
gen date = ym(year, month2)
format date %tm
encode from, gen(name)

//Gerar agregados
sort name year month2
bysort name year month2: egen likes_mth = sum(likes)
bysort name year month2: egen comments_mth = sum(comments)
bysort name year month2: egen shares_mth = sum(shares)

//Salvar banco
save facebook2.dta, replace

//Usar banco
use facebook2.dta, replace

//Eliminar duplicados
bysort name year month2: gen dup = cond(_N==1,0,_n)
drop if dup>1

//Definir serie temporal
xtset name date

//Eliminar antes de 2013
drop if year<2013
// Deixar a linha do Ciro acima da linha da Marina
replace name = 10 if name ==1 

//Graficos
xtline likes_mth if name!=5, overlay  plot1(lc(cyan)) plot2(lc(gs2)) plot3(lc(blue)) plot4(lc(red)) plot5(lc(green)) plot6(lc(pink)) legend(off) /*
*/ tlabel(2013m1(12)2017m6) 
graph export likes.png, width(2000) replace

xtline shares_mth if name!=5, overlay  plot1(lc(cyan)) plot2(lc(gs2)) plot3(lc(blue)) plot4(lc(red)) plot5(lc(green)) plot6(lc(pink)) legend(off) /*
*/ tlabel(2013m1(12)2017m6)
graph export shares.png, width(2000) replace

xtline comments_mth if name!=5, overlay  plot1(lc(cyan)) plot2(lc(gs2)) plot3(lc(blue)) plot4(lc(red)) plot5(lc(green)) plot6(lc(pink)) legend(off) /*
*/ tlabel(2013m1(12)2017m6)
graph export comments.png, width(2000) replace
