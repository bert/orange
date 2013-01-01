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
 *
 */
public class Simulation : ProjectNode
{
    /**
     * The default gnetlist backend to use for generating netlists.
     */
    public const string DEFAULT_BACKEND = "spice-sdb";



    /**
     * The default engine to use for generating netlists.
     *
     * This constant is the internal identifier of the engine, not the
     * name of the program at the command line.
     */
    public const string DEFAULT_ENGINE = "ngspice";



    /**
     * The suffix to use for netlist files.
     */
    private const string NETLIST_SUFFIX = ".cir";



    /**
     * The XML element name for a simulation node.
     */
    public const string ELEMENT_NAME = "sim";



    /**
     * The XML property name for the gnetlist backend.
     */
    private const string PROP_BACKEND = "backend";



    /**
     * The XML property name for the circuit filename.
     */
    private const string PROP_CIRCUIT = "circuit";



    /**
     * The XML property name for the circuit filename.
     */
    private const string PROP_ENGINE = "engine";


    /**
     * The XML property name for the netlist filename.
     */
    private const string PROP_NETLIST = "netlist";



    /**
     * The XML property name for the simulation subdirectory.
     */
    private const string PROP_SUBDIR = "subdir";



    /**
     * To preserve a reference to an unowned return value
     */
    private string m_name;



    /**
     * To preserve a reference to an unowned return value
     */
    private string m_path;



    /**
     * The name of the gnetlist backend to use for creating netlists
     */
    public string backend
    {
        owned get
        {
            return element->get_prop(PROP_BACKEND);
        }
        set
        {
            element->set_prop(PROP_BACKEND, value);
        }
    }



    /**
     * The name of the gnetlist backend to use for creating netlists
     */
    public string circuit
    {
        owned get
        {
            return element->get_prop(PROP_CIRCUIT);
        }
    }



    /**
     * The XML element associated with this node.
     */
    public Xml.Node* element
    {
        get;
        private set;
    }



    /**
     * The engine to use for simulation
     */
    public string engine
    {
        owned get
        {
            return element->get_prop(PROP_ENGINE);
        }
        set
        {
            element->set_prop(PROP_ENGINE, value);
        }
    }



    /**
     * The name of the node
     *
     * For schematics, the basename of the file is used as the name.
     */
    public override string name
    {
        get
        {
            return m_name = subdir;
        }
    }



    /**
     * The filename of the netlist for this simulation
     */
    public string netlist
    {
        owned get
        {
            return element->get_prop(PROP_NETLIST);
        }
    }



    /**
     * The name of the subdirectory for this simulation
     */
    public string subdir
    {
        owned get
        {
            return element->get_prop(PROP_SUBDIR);
        }
    }



    /**
     * The path to the directory for this simulation
     */
    public override string path
    {
        get
        {
            return m_path = Path.build_filename(
                parent.path,
                subdir
                );
        }
    }



    /*
     *
     *
     *
     */
    private Simulation(ProjectNode parent, Xml.Node* element)

        requires(element != null)

    {
        base(parent);
        this.element = element;
    }



    /*
     *
     * param subdir The basename to use for the path to this simulation
     */
    public static Simulation create(ProjectNode parent, string subdir)
    {
        Xml.Node* element = new Xml.Node(null, ELEMENT_NAME);

        element->set_prop(PROP_SUBDIR, subdir);

        element->set_prop(PROP_ENGINE, DEFAULT_ENGINE);

        element->set_prop(PROP_CIRCUIT, subdir + NETLIST_SUFFIX);

        element->set_prop(PROP_NETLIST, subdir + NETLIST_SUFFIX);

        element->set_prop(PROP_BACKEND, DEFAULT_BACKEND);

        return new Simulation(parent, element);
    }



    /*
     *
     *
     *
     */
    public static Simulation load(ProjectNode parent, Xml.Node* element)

        requires(element != null)

    {
        return new Simulation(parent, element);
    }



    public override void add_to_batch(Batch batch)
    {
        batch.add_simulation(this);
    }



    public void run() throws Error
    {
        create_netlist();
        start_simulation();
    }



    /**
     * Create the netlist used for this simulation.
     *
     * Similar to code in ExportNetlistBatch.vala and should be refactored.
     */
    private void create_netlist() throws Error
    {
        var arguments = new Gee.ArrayList<string?>();

        arguments.add("gnetlist");

        arguments.add("-g");
        arguments.add(backend);

        arguments.add("-o");
        arguments.add(Path.build_filename(path, netlist));

        foreach (var schematic in design.schematics)
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

        int status;

        Process.spawn_sync(
            design.path,
            arguments.to_array(),
            environment.to_array(),
            SpawnFlags.SEARCH_PATH,
            null,
            null,
            null,
            out status
            );

        if (status != 0)
        {
            // throw something
        }
    }



    /**
     * Begin the simulation.
     */
    private void start_simulation() throws Error
    {
        Gee.ArrayList<string?> arguments;

        switch (engine)
        {
            case "gnucap":
                arguments = create_arguments_gnucap();
                break;

            case "ngspice":
            default:
                arguments = create_arguments_ngspice();
                break;
        }

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
                environment.add("%s=%s".printf(variable, path));
            }
            else
            {
                environment.add("%s=%s".printf(variable, Environment.get_variable(variable)));
            }
        }

        foreach (var variable in environment)
        {
            stdout.printf("%s\n", variable);
        }

        stdout.flush();

        environment.add(null);

        Process.spawn_async(
            path,
            arguments.to_array(),
            environment.to_array(),
            SpawnFlags.SEARCH_PATH,
            null,
            null
            );
    }



    /**
     * Build command arguments for invoking ngspice
     *
     * When invoking ngspice directly, the program cannot locate the display. The
     * current fix is to launch it in interactive mode in its own xterm.
     */
    Gee.ArrayList<string?> create_arguments_ngspice()
    {
        var arguments = new Gee.ArrayList<string?>();

        arguments.add("xterm");
        arguments.add("-e");

        arguments.add("ngspice");
        arguments.add("-i");

        arguments.add(Path.build_filename(path, circuit));

        arguments.add(null);

        return arguments;
    }



    Gee.ArrayList<string?> create_arguments_gnucap()
    {
        var arguments = new Gee.ArrayList<string?>();

        arguments.add("gnucap");

        arguments.add("-i");
        arguments.add(Path.build_filename(path, circuit));

        arguments.add(null);

        return arguments;
    }



    /*
     *
     *  The simulation currently has no child nodes, so this function returns 0.
     *
     */
    public override int get_child_count()
    {
        return 0;
    }



    /*
     *
     *  The schematic has no child nodes, so this function returns null.
     *
     */
    public override ProjectNode? get_child(int index)
    {
        return null;
    }



    /*
     *
     *  The schematic has no child nodes, so this function returns false.
     *
     */
    public override bool get_child_index(ProjectNode child, out int index)
    {
        index = 0;
        return false;
    }
}
