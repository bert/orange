
imgdir = $(pkgdatadir)/img
xmldir = $(pkgdatadir)/xml

AM_CPPFLAGS = $(DEPS_CFLAGS) -DIMAGE_DIR=\"$(imgdir)\" -DPKGDATADIR=\"$(pkgdatadir)\" -include config.h
AM_VALAFLAGS = --target-glib=2.38 --pkg gee-1.0 --pkg gtk+-3.0 --pkg libxml-2.0


# additional variables and rules for compiling GTK resources
#
# Automatic dependencies isn't working yet
#

GCR = glib-compile-resources

SUFFIXES = .xml

.xml.c:
	$(GCR) --target=$@ --generate-source $<
#	$(GCR) --target=$@ --generate-dependencies $<

Orange.gresource.c : \
	AboutDialog.xml \
	AboutDialog.xml \
	AddSimulationDialog.xml \
	ArchiveSchematicsDialog.xml \
	BackannotateRefdesDialog.xml \
	ExportBOMDialog.xml \
	ExportNetlistDialog.xml \
	MainWindow.xml \
	NewDesignDialog.xml \
	NewProjectDialog.xml \
	Program.xml \
	RenumberRefdesDialog.xml \
	ResetRefdesDialog.xml

# orange program

bin_PROGRAMS = orange

orange_SOURCES = \
	AboutDialog.vala \
	AddSimulation.vala \
	AddSimulationDialog.vala \
	ArchiveSchematics.vala \
	ArchiveSchematicsDialog.vala \
	BackannotateRefdes.vala \
	BackannotateRefdesDialog.vala \
	Batch.vala \
	BatchController.vala \
	DeleteBatch.vala \
	Design.vala \
	DesignAddExistingBatch.vala \
	DesignAddNewBatch.vala \
	DialogFactory.vala \
	EditBatch.vala \
	ExportBOMBatch.vala \
	ExportBOMDialog.vala \
	ExportNetlistBatch.vala \
	ExportNetlistDialog.vala \
	ExportPrintBatch.vala \
	MainWindow.vala \
	NewDesignDialog.vala \
	NewProjectDialog.vala \
	OpenDirectory.vala \
	Orange.gresource.xml \
	PixbufCache.vala \
	Project.vala \
	ProjectController.vala \
	ProjectError.vala \
	ProjectNode.vala \
	ProjectList.vala \
	ProjectTreeModel.vala \
	Program.vala \
	RenumberRefdes.vala \
	RenumberRefdesDialog.vala \
	ResetRefdes.vala \
	ResetRefdesDialog.vala \
	RunSimulation.vala \
	Schematic.vala \
	SchematicList.vala \
	Simulation.vala \
	SimulationList.vala

orange_LDADD = -lm $(DEPS_LIBS)

# Image files for the GUI

img_DATA = \
	img/schematic.svg \
	img/schematic-folder.svg \
	img/simulation-folder.svg

# GtkBuilder XML Files used for the user interface

xml_DATA = \
	AddSimulationDialog.xml \
	ArchiveSchematicsDialog.xml \
	BackannotateRefdesDialog.xml \
	RenumberRefdesDialog.xml \
	ResetRefdesDialog.xml

# Needs improvement

documentation:
	valadoc --vapidir=/usr/share/vala-0.14/vapi -o ../doc $(AM_VALAFLAGS) $(orange_SOURCES)
