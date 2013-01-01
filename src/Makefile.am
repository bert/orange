
AM_CPPFLAGS = $(DEPS_CFLAGS) -DPKGDATADIR=\"$(pkgdatadir)\"
AM_VALAFLAGS = --pkg gee-1.0 --pkg gtk+-2.0 --pkg libxml-2.0

bin_PROGRAMS = orange

orange_SOURCES = \
	AddSimulation.vala \
	AddSimulationDialog.vala \
	ArchiveSchematics.vala \
	ArchiveSchematicsDialog.vala \
	BackannotateRefdes.vala \
	BackannotateRefdesDialog.vala \
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
	RenumberRefdes.vala \
	RenumberRefdesDialog.vala \
	RunSimulation.vala \
	Schematic.vala \
	SchematicList.vala \
	Simulation.vala \
	SimulationList.vala

orange_LDADD = $(DEPS_LIBS)

# GtkBuilder XML Files used for the user interface

xmldir = $(pkgdatadir)/xml

xml_DATA = \
	AddSimulationDialog.xml \
	ArchiveSchematicsDialog.xml \
	BackannotateRefdesDialog.xml \
	ExportBOMDialog.xml \
	ExportNetlistDialog.xml \
	NewDesignDialog.xml \
	NewProjectDialog.xml \
	Program.xml \
	RenumberRefdesDialog.xml

# Needs improvement

documentation:
	valadoc --vapidir=/usr/share/vala-0.14/vapi -o ../doc $(AM_VALAFLAGS) $(orange_SOURCES)
