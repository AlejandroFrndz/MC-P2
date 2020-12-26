all: compilar

compilar:
	flex++ practica2.l
	g++ lex.yy.cc -o HTMLDM3000
	./HTMLDM3000  access.log