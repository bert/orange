AC_INIT([orange],[0.0])

AC_CONFIG_HEADER([config.h])
AM_INIT_AUTOMAKE
AC_PROG_CC
AM_PROG_VALAC([0.14.0])

AC_CONFIG_FILES([
	Makefile
	src/Makefile
	])

PKG_CHECK_MODULES([DEPS], [
	gee-1.0  >= 0.6.4
	glib-2.0 >= 2.32.3
	gtk+-2.0 >= 2.24.10
	libxml-2.0 >= 2.7.8
	])

AC_OUTPUT

