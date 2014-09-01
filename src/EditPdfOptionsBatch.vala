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
    /**
     * A batch operation to export prints in the project tree.
     */
    public class EditPdfOptionsBatch : Batch
    {
        /**
         * A set of all the designs in the batch operation.
         *
         * The operation uses a set to eliminate duplicates.
         */
        private Gee.HashSet<Design> m_designs;



        /**
         * Create a new, empty batch operation.
         */
        public EditPdfOptionsBatch(DialogFactory factory, SimpleAction action)
        {
            base(factory, action);

            m_designs = new Gee.HashSet<Design>();

            update();
        }



        /**
         * Add a schematic to the batch operation.
         */
        public override void add_design(Design design)
        {
            m_designs.add(design);
        }



        /**
         * Clear all nodes from the batch operation.
         */
        public override void clear()
        {
            m_designs.clear();
        }



        /**
         * Determines if the current batch is editable.
         */
        public override bool enabled()
        {
            return (m_designs.size == 1);
        }



        /**
         * Run the batch operation.
         */
        public override void run() throws Error
        {
            foreach (var design in m_designs)
            {
                var dialog = new EditPdfOptionsDialog();
                dialog.set_transient_for(m_factory.Parent);

                var options = ExportPdfOptions();
                design.retrieve_export_pdf_options(ref options);
                dialog.set_options(&options);

                int status = dialog.run();
                dialog.hide();

                if (status == Gtk.ResponseType.CANCEL)
                {
                    continue;
                }

                design.store_export_pdf_options(dialog.get_options());
            }
        }
    }
}
