/*
 *  Copyright (C) 2013 Edward Hennessy
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
     * A batch operation to reset the REFDES in a design.
     */
    public class ResetRefdes : Batch
    {
        /**
         * The command line application to reset REFDES.
         */
        private const string RESET_COMMAND = "sed";



        /**
         * The sed substitute argument to replace refdes numbers with a question mark.
         */
        private const string SUBSTITUE_ARG = "s/^\\(refdes=[A-Z][A-Z]*\\)[0-9][0-9]*/\\1\\?/I";



        /**
         * An argument to operate on the file inplace.
         */
        private const string INPLACE_ARG = "-i.bak";



        /**
         * A set of all the designs in the batch operation.
         *
         * The operation uses a set to eliminate duplicates.
         */
        private Gee.HashSet<Design> m_designs;



        /**
         * Create a new, empty batch operation.
         */
        public ResetRefdes(DialogFactory factory, Gtk.Action action)
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
            return (m_designs.size >= 1);
        }



        /**
         * Run the batch operation.
         */
        public override void run() throws Error
        {
            foreach (var design in m_designs)
            {
                var dialog = m_factory.create_reset_refdes_dialog();

                int status = dialog.run();
                dialog.hide();

                if (status == Gtk.ResponseType.OK)
                {
                    foreach (Schematic schematic in design.schematics)
                    {
                        var arguments = new Gee.ArrayList<string?>();

                        arguments.add(RESET_COMMAND);

                        arguments.add(SUBSTITUE_ARG);

                        arguments.add(INPLACE_ARG);

                        arguments.add(schematic.basename);

                        arguments.add(null);

                        int exit_code;

                        Process.spawn_sync(
                            design.path,
                            arguments.to_array(),
                            null,
                            SpawnFlags.SEARCH_PATH,
                            null,
                            null,
                            null,
                            out exit_code
                            );

                        if (exit_code != 0)
                        {
                            // throw something
                        }
                    }
                }
            }
        }
    }
}
