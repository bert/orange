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

using GLib;

namespace Orange
{
    /**
     * A batch operation to edit nodes in the project tree.
     */
    public class EditBatch : Batch
    {
        /**
         * The command line application to edit schematics.
         */
        private const string EDIT_SCHEMATIC_COMMAND = "gschem";



        /**
         * A set of all the schematics in the batch operation.
         *
         * The operation uses a set to eliminate duplicates.
         */
        private Gee.HashSet<Schematic> m_schematics;



        /**
         * Create a new, empty batch operation.
         */
        public EditBatch(DialogFactory factory, SimpleAction action)
        {
            base(factory, action);

            m_schematics = new Gee.HashSet<Schematic>();

            update();
        }



        /**
         * Add a schematic to the batch operation.
         */
        public override void add_schematic(Schematic schematic)

            requires(m_schematics != null)

        {
            m_schematics.add(schematic);
        }



        /**
         * Clear all nodes from the batch operation.
         */
        public override void clear()

            requires(m_schematics != null)

        {
            m_schematics.clear();
        }



        /**
         * Determines if the current batch is editable.
         */
        public override bool enabled()

            requires(m_schematics != null)

        {
            return (m_schematics.size > 0);
        }



        /**
         * Run the batch operation.
         *
         * This batch operation launches a separate schematic editor per design,
         * so each instance can have the correct working directory for each
         * set of schematics. This operation also orders the schematics on the
         * command line in the same order that they appear in the project tree.
         */
        public override void run() throws Error

            requires(m_schematics != null)

        {
            var designs = new Gee.HashSet<Design>();

            foreach (var schematic in m_schematics)
            {
                designs.add(schematic.design);
            }

            foreach (var design in designs)
            {
                var arguments = new Gee.ArrayList<string?>();

                arguments.add(EDIT_SCHEMATIC_COMMAND);

                foreach (Schematic schematic in design.schematics)
                {
                    if (schematic in m_schematics)
                    {
                        arguments.add(schematic.basename);
                    }
                }

                arguments.add(null);

                /*  Ensure the environment variables OLDPWD and PWD match the
                 *  working directory passed into Process.spawn_async(). Some
                 *  Scheme scripts use getenv() to determine the current
                 *  working directory.
                 */

                var environment = new Gee.ArrayList<string?>();

                foreach (string variable in Environment.list_variables())
                {
                    if (variable == "OLDPWD")
                    {
                        environment.add("%s=%s".printf(variable, Environment.get_current_dir()));
                    }
                    else if (variable == "PWD")
                    {
                        environment.add("%s=%s".printf(variable, design.path));
                    }
                    else
                    {
                        environment.add("%s=%s".printf(variable, Environment.get_variable(variable)));
                    }
                }

                environment.add(null);

                Process.spawn_async(
                    design.path,
                    arguments.to_array(),
                    environment.to_array(),
                    SpawnFlags.SEARCH_PATH,
                    null,
                    null
                    );
            }
        }
    }
}
