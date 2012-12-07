
AM_CPPFLAGS = $(DEPS_CFLAGS) -DPKGDATADIR=\"$(pkgdatadir)\"
AM_VALAFLAGS = --pkg gee-1.0 --pkg gtk+-2.0 --pkg libxml-2.0

bin_PROGRAMS = orange

orange_SOURCES = \
	Batch.vala \
	BatchController.vala \
	Design.vala \
	DesignAddExistingBatch.vala \
	DialogFactory.vala \
	EditBatch.vala \
	ExportBOMBatch.vala \
	ExportBOMDialog.vala \
	ExportNetlistBatch.vala \
	ExportNetlistDialog.vala \
	ExportPrintBatch.vala \
	NewDesignDialog.vala \
	NewProjectDialog.vala \
	Project.vala \
	ProjectController.vala \
	ProjectError.vala \
	ProjectNode.vala \
	ProjectList.vala \
	ProjectTreeModel.vala \
	Program.vala \
	Schematic.vala \
	SchematicList.vala

orange_LDADD = $(DEPS_LIBS)

# GtkBuilder XML Files used for the user interface

xmldir = $(pkgdatadir)/xml

xml_DATA = \
	ExportBOMDialog.xml \
	ExportNetlistDialog.xml \
	NewDesignDialog.xml \
	NewProjectDialog.xml \
	Program.xml

