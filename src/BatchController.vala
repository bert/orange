/*
 *  Copyright (C) 2012 Edward Hennessy
 *
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License
 *  as published by the Free Software Foundation; either version 2
 *  of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */
namespace Orange
{
    /*
     *
     *
     *
     */
    public class BatchController
    {
        private Gee.ArrayList<Batch> m_batches;

        public Gee.List<Batch> batches
        {
            owned get
            {
                return m_batches.read_only_view;
            }
        }


        public BatchController(DialogFactory factory)
        {
            m_batches = new Gee.ArrayList<Batch>();

            m_batches.add(new DesignAddNewBatch(
                factory,
                new SimpleAction("design-add-schematic-new", null)
                ));

            m_batches.add(new DesignAddExistingBatch(
                factory,
                new SimpleAction("design-add-schematic-existing", null)
                ));

            m_batches.add(new DeleteBatch(
                factory,
                new SimpleAction("edit-delete", null)
                ));

            m_batches.add(new EditBatch(
                factory,
                new SimpleAction("edit-edit", null)
                ));

            m_batches.add(new OpenDirectory(
                factory,
                new SimpleAction("edit-open-directory", null)
                ));

            m_batches.add(new ExportBOMBatch(
                factory,
                new SimpleAction("file-export-bom", null)
                ));

            m_batches.add(new ExportNetlistBatch(
                factory,
                new SimpleAction("file-export-netlist", null)
                ));

            m_batches.add(new ExportPrintBatch(
                factory,
                new SimpleAction("file-export-pdf", null)
                ));

            m_batches.add(new RenumberRefdes(
                factory,
                new SimpleAction("design-renumber-refdes", null)
                ));

            m_batches.add(new ResetRefdes(
                factory,
                new SimpleAction("design-reset-refdes", null)
                ));

            m_batches.add(new ArchiveSchematics(
                factory,
                new SimpleAction("design-archive-schematics", null)
                ));

            m_batches.add(new BackannotateRefdes(
                factory,
                new SimpleAction("design-backannotate-refdes", null)
                ));

            m_batches.add(new AddSimulation(
                factory,
                new SimpleAction("design-add-simulation", null)
                ));

            m_batches.add(new RunSimulation(
                factory,
                new SimpleAction("design-run-simulation", null)
                ));
        }



        public void set_selection(List<ProjectNode> selection)

            requires(m_batches != null)

        {
            foreach (Batch batch in m_batches)
            {
                batch.clear();
            }

            foreach (var node in selection)
            {
                foreach (Batch batch in m_batches)
                {
                    node.add_to_batch(batch);
                }
            }

            foreach (Batch batch in m_batches)
            {
                batch.update();
            }
        }
    }
}
