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
 * A batch operation to renumber the REFDES in a design.
 */
public class RenumberRefdes : Batch
{
    /**
     * The command line application to renumber REFDES.
     */
    private const string RENUMBER_COMMAND = "refdes_renum";



    /**
     * A set of all the designs in the batch operation.
     *
     * The operation uses a set to eliminate duplicates.
     */
    private Gee.HashSet<Design> m_designs;



    /**
     * Create a new, empty batch operation.
     */
    public RenumberRefdes(DialogFactory factory, Gtk.Action action)
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
            var dialog = m_factory.create_renumber_refdes_dialog();

            int status = dialog.run();
            dialog.hide();

            if (status == Gtk.ResponseType.OK)
            {
                var arguments = new Gee.ArrayList<string?>();

                arguments.add(RENUMBER_COMMAND);

                if (dialog.get_force_renumber())
                {
                    arguments.add("--force");
                }

                if (dialog.get_include_page_numbers())
                {
                    arguments.add("--pgskip");
                    arguments.add(dialog.get_page_number_param());
                }

                foreach (Schematic schematic in design.schematics)
                {
                    arguments.add(schematic.basename);
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
