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
/**
 *  A batch operation to add an existing schematic to a design.
 */
public class DesignAddExistingBatch : Batch
{
    /**
     *  A set of all the designs in the batch operation.
     *
     *  The operation uses a set to eliminate duplicates.
     */
    private Gee.HashSet<Design> m_designs;



    /**
     *  Create a new, empty batch operation.
     */
    public DesignAddExistingBatch(DialogFactory factory, Gtk.Action action)
    {
        base(factory, action);

        m_designs = new Gee.HashSet<Design>();
    }



    /**
     *  Add a schematic to the batch operation.
     */
    public override void add_design(Design design)
    {
        m_designs.add(design);
    }



    /**
     *  Clear all nodes from the batch operation.
     */
    public override void clear()
    {
        m_designs.clear();
    }



    /**
     *  Determines if the current batch is editable.
     */
    public override bool enabled()
    {
        return (m_designs.size == 1);
    }



    /**
     *  Run the batch operation.
     */
    public override void run() throws Error
    {
        foreach (var design in m_designs)
        {
            string dirname = design.path;

            var dialog = create_open_dialog(dirname);

            int status = dialog.run();
            dialog.hide();

            if (status == Gtk.ResponseType.OK)
            {
                design.add_existing_schematic(dialog.get_filename());
            }

        }
    }



    private Gtk.FileChooserDialog create_open_dialog(string dirname)
    {
        var dialog = new Gtk.FileChooserDialog(
            "Add Existing Schematic",
            m_factory.Parent,
            Gtk.FileChooserAction.OPEN,
            Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL,
            Gtk.Stock.OK,     Gtk.ResponseType.OK,
            null
            );

        dialog.set_current_folder(dirname);

        return dialog;
    }

}

