func main
	C_LINESIZE = 80
	? copy("=",C_LINESIZE)
	? "Solitaire Package"
	? copy("=",C_LINESIZE)
	? "Solitaire package for the Ring programming language"
	? "See the folder : ring/applications/solitaire"
	? copy("=",C_LINESIZE)
	cDir = currentdir()
	chdir(exefolder()+"/../applications/solitaire")
	system("ring solitaire.ring")
	chdir(cDir)