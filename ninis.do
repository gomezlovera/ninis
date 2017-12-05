* NINIS
* Marco Antonio Gomez Lovera
* marco.gomez[at]colmex.mx

set more off
clear all
cd "/Volumes/MarcoHDD3/Colmex/Curiosidades"
global database "/Volumes/MarcoHDD3/DataBase/ENOE"

use "$database/2005/1T/sdemt105.dta", clear
keep r_def c_res eda clase2 cs_p17 clase1 pnea_est c_inac5c cs_p13_1 cs_p13_2 cs_p15 fac
destring _all, replace
keep if r_def==0 & c_res!=2
keep if eda>=14 & eda<=29

* PRIMERA DEFINICIÓN
* Jóvenes entre 15 y 29 años que ni estudian ni trabajan
* PEA desocupados y no estudian
gen nini1=1 if clase2==2 & cs_p17==2
* PNEA que no estudian
replace nini1=1 if clase1==2 & cs_p17==2
replace nini1=0 if nini1==.
* Menos impedimento físico para estudiar o trabajar
replace nini1=0 if nini1==1 & (pnea_est==5 | c_inac5c==4)

* SEGUNDA DEFINICIÓN
* Jóvenes entre 15 y 29 años que ni estudian ni trabajan ni se dedican al hogar
gen nini2=nini1
* Menos no disponibles por labores del hogar
replace nini2=0 if c_inac5c==2 

* TERCERA DEFINICIÓN
* Jóvenes entre 15 y 29 años que ni estudian ni trabajan ni tienen el nivel
* educativo deseado para su edad
gen nini3=nini1
* Generamos años de educación acumulada
gen aeduc=0 if cs_p13_1==0
replace aeduc=cs_p13_2 if cs_p13_1==2
replace aeduc=cs_p13_2+6 if cs_p13_1==3
replace aeduc=cs_p13_2+6 if cs_p13_1==5 & cs_p15==1
replace aeduc=cs_p13_2+6 if cs_p13_1==6 & cs_p15==1
replace aeduc=cs_p13_2+9 if cs_p13_1==4
replace aeduc=cs_p13_2+9 if cs_p13_1==5 & cs_p15==2
replace aeduc=cs_p13_2+9 if cs_p13_1==6 & cs_p15==2
replace aeduc=cs_p13_2+12 if cs_p13_1==7
replace aeduc=cs_p13_2+12 if cs_p13_1==5 & cs_p15==3
replace aeduc=cs_p13_2+12 if cs_p13_1==6 & cs_p15==3
replace aeduc=cs_p13_2+16 if cs_p13_1==8
replace aeduc=cs_p13_2+18 if cs_p13_1==9
replace aeduc=. if cs_p13_1==99
* Quitamos condición de ninis si tienen la educación esperada para su edad
replace nini3=0 if eda<=15 & aeduc>=6
replace nini3=0 if eda==16 & aeduc>=9
replace nini3=0 if (eda==17 | eda==18) & aeduc>=10
replace nini3=0 if eda>18 & aeduc>=12

* CUARTA DEFINICIÓN
* Jóvenes entre 14 y 24 años que ni estudian ni trabajan
gen nini4=nini1
replace nini4=0 if eda==14 | eda>24

collapse (sum) nini1 nini2 nini3 nini4 [fw=fac]
gen year=2005
gen qr=1

save "ninis.dta", replace

foreach x in 05 06 07 08 09 10 11 12 13 14 15 16 17{
foreach i in 1 2 3 4{
use "$database/20`x'/`i'T/sdemt`i'`x'.dta", clear
keep r_def c_res eda clase2 cs_p17 clase1 pnea_est c_inac5c cs_p13_1 cs_p13_2 cs_p15 fac
destring _all, replace
keep if r_def==0 & c_res!=2
keep if eda>=14 & eda<=29

* PRIMERA DEFINICIÓN
* PEA desocupados y no estudian
gen nini1=1 if clase2==2 & cs_p17==2
* PNEA que no estudian
replace nini1=1 if clase1==2 & cs_p17==2
replace nini1=0 if nini1==.
* Menos impedimento físico para estudiar o trabajar
replace nini1=0 if nini1==1 & (pnea_est==5 | c_inac5c==4)

* SEGUNDA DEFINICIÓN
gen nini2=nini1
* Menos no disponibles por labores del hogar
replace nini2=0 if c_inac5c==2 

* TERCERA DEFINICIÓN
gen nini3=nini1
* Generamos años de educación acumulada
gen aeduc=0 if cs_p13_1==0
replace aeduc=cs_p13_2 if cs_p13_1==2
replace aeduc=cs_p13_2+6 if cs_p13_1==3
replace aeduc=cs_p13_2+6 if cs_p13_1==5 & cs_p15==1
replace aeduc=cs_p13_2+6 if cs_p13_1==6 & cs_p15==1
replace aeduc=cs_p13_2+9 if cs_p13_1==4
replace aeduc=cs_p13_2+9 if cs_p13_1==5 & cs_p15==2
replace aeduc=cs_p13_2+9 if cs_p13_1==6 & cs_p15==2
replace aeduc=cs_p13_2+12 if cs_p13_1==7
replace aeduc=cs_p13_2+12 if cs_p13_1==5 & cs_p15==3
replace aeduc=cs_p13_2+12 if cs_p13_1==6 & cs_p15==3
replace aeduc=cs_p13_2+16 if cs_p13_1==8
replace aeduc=cs_p13_2+18 if cs_p13_1==9
replace aeduc=. if cs_p13_1==99
* Quitamos condición de ninis si tienen la educación esperada para su edad
replace nini3=0 if eda<=15 & aeduc>=6
replace nini3=0 if eda==16 & aeduc>=9
replace nini3=0 if (eda==17 | eda==18) & aeduc>=10
replace nini3=0 if eda>18 & aeduc>=12

* CUARTA DEFINICIÓN
gen nini4=nini1
replace nini4=0 if eda==14 | eda>24

collapse (sum) nini1 nini2 nini3 nini4 [fw=fac]
gen year=2000+`x'
gen qr=`i'

append using "ninis.dta"
save "ninis.dta", replace
}
}

use "ninis.dta", clear
order year qr n*
sort year qr
drop in 1

gen periodo = _n + 179
tsset periodo, quarterly

label define scale 0 "0" 2000000 "2" 4000000 "4" 6000000 "6" 8000000 "8"
label values nini1 scale
label values nini2 scale
label values nini3 scale
label values nini4 scale

tsline nini1 nini2 nini3 nini4, ///
	xtitle("Año") xlabel(180 192 204 216 228,format(%tqCY)) ylabel(,format(%9.0fc) valuelabel) ///
	ytitle("Jóvenes (millones)") legend(size(small)) lpattern(solid) ///
	scheme(s2mono) graphr(fcolor(white)) graphregion(lcolo(white)) ///
	legend(order(1 "Ni estudian ni trabajan" 2 "Nini, ni atiende hogar" ///
	3 "Nini sin educación deseada a su edad" 4 "Nini (15-24 años)")) ///
	title("Ninis en México") note("Fuente: ENOE, INEGI")
graph export "ninis.eps", replace

save "ninis.dta", replace
