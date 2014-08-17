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

using GLib;

namespace Orange
{
    /**
     * A batch operation to delete nodes in the project tree.
     */
    public class OpenDirectory : Batch
    {
        /**
         * The program to open directories with
         *
         * This program will need to become a config item in the future.
         */
        private static const string PROGRAM = "nautilus";



        /**
         * A set of all the schematics in the batch operation.
         *
         * The operation uses a set to eliminate duplicates.
         */
        private Gee.HashSet<ProjectNode> m_nodes;



        /**
         * Create a new, empty batch operation.
         */
        public OpenDirectory(DialogFactory factory, Gtk.Action action)
        {
            base(factory, action);

            m_nodes = new Gee.HashSet<ProjectNode>();

            update();
        }



        /**
         * Add a design to the batch operation.
         */
        public override void add_design(Design design)

            requires(m_nodes != null)

        {
            m_nodes.add(design);
        }



        /**
         * Add a schematic to the batch operation.
         */
        public override void add_schematic(Schematic schematic)

            requires(m_nodes != null)

        {
            m_nodes.add(schematic);
        }



        /**
         * Clear all nodes from the batch operation.
         */
        public override void clear()

            requires(m_nodes != null)

        {
            m_nodes.clear();
        }



        /**
         * Determines if the current batch is editable.
         */
        public override bool enabled()

            requires(m_nodes != null)

        {
            return (m_nodes.size == 1);
        }



        /**
         * Run the batch operation.
         */
        public override void run() throws Error

            requires(m_nodes != null)
            requires(m_nodes.size == 1)

        {
            /* This loop is intended to execute once, HashSet lacks a .first() method */

            foreach (ProjectNode node in m_nodes)
            {
                string directory = node.path;

                if (!FileUtils.test(directory, FileTest.IS_DIR))
                {
                    // throw something
                }

                var arguments = new Gee.ArrayList<string?>();

                arguments.add(PROGRAM);
                arguments.add(directory);
                arguments.add(null);

                Process.spawn_async(
                    directory,
                    arguments.to_array(),
                    null,
                    SpawnFlags.SEARCH_PATH,
                    null,
                    null
                    );
            }
        }
    }
}
