AC_INIT([Orange],[0.0],[],[orange],[http://geda-project.org])
AC_PREREQ([2.64])

AC_CONFIG_HEADER([config.h])
AM_INIT_AUTOMAKE
AC_PROG_CC
AM_PROG_VALAC([0.20.0])

AC_CONFIG_FILES([
	Makefile
	data/Makefile
	src/AboutDialog.xml
	src/Makefile
	])

PKG_CHECK_MODULES([DEPS], [
	gee-1.0  >= 0.6.4
	glib-2.0 >= 2.38.1
	gtk+-3.0 >= 3.8.6
	libxml-2.0 >= 2.7.8
	])

AC_OUTPUT

