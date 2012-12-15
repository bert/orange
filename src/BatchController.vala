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
/*
 *
 *
 *
 */
public class BatchController
{
    private Gee.ArrayList<Batch> m_batches;


    public BatchController(DialogFactory factory, Gtk.Builder builder)
    {
        m_batches = new Gee.ArrayList<Batch>();

        m_batches.add(new DesignAddExistingBatch(
            factory,
            builder.get_object("design-add-schematic") as Gtk.Action
            ));

        m_batches.add(new EditBatch(
            factory,
            builder.get_object("edit-edit") as Gtk.Action
            ));

        m_batches.add(new ExportBOMBatch(
            factory,
            builder.get_object("file-export-bom") as Gtk.Action
            ));

        m_batches.add(new ExportNetlistBatch(
            factory,
            builder.get_object("file-export-netlist") as Gtk.Action
            ));

        m_batches.add(new ExportPrintBatch(
            factory,
            builder.get_object("file-export-pdf") as Gtk.Action
            ));

        m_batches.add(new RenumberRefdes(
            factory,
            builder.get_object("design-renumber-refdes") as Gtk.Action
            ));

        m_batches.add(new ArchiveSchematics(
            factory,
            builder.get_object("design-archive-schematics") as Gtk.Action
            ));

        m_batches.add(new BackannotateRefdes(
            factory,
            builder.get_object("design-backannotate-refdes") as Gtk.Action
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
