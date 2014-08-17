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
     * A container for simulations in the project tree
     */
    public class SimulationList : ProjectNode
    {
        /**
         * A continer to store the list of schematics.
         */
        private Gee.ArrayList<Simulation> m_simulations;



        public override unowned Gdk.Pixbuf icon
        {
            get
            {
                return pixbufs.fetch("simulation-folder.svg");
            }
        }



        /**
         * A name, visible to the user, for this node in the project tree.
         */
        public override string name
        {
            get
            {
                return "sim";
            }
        }


        private string m_path;


        public override string path
        {
            get
            {
                return m_path = Path.build_filename(
                    parent.path,
                    "sim"
                    );
            }
        }



        public Gee.List<Simulation> simulations
        {
            owned get
            {
                return m_simulations.read_only_view;
            }
        }


        /**
         * Create a container for schematics
         *
         * param parent The parent node for this container.
         */
        private SimulationList(PixbufCache pixbufs, ProjectNode parent)
        {
            base(pixbufs, parent);
            m_simulations = new Gee.ArrayList<Simulation>();
        }



        /**
         * Create a container for simulations
         *
         * param parent The parent node for this container.
         */
        public static SimulationList create(PixbufCache pixbufs, ProjectNode parent)
        {
            return new SimulationList(pixbufs, parent);
        }



        /**
         * Add the simulation list to the batch operation.
         *
         * Selecting the simulation list in the project tree is the
         * same as selecting all the simulation within.
         */
        public override void add_to_batch(Batch batch)

            requires(m_simulations != null)

        {
            foreach (var simulation in m_simulations)
            {
                batch.add_simulation(simulation);
            }
        }



        /**
         * Add a simulation to the list
         *
         * param node The XML node representing the schematic. This node must
         * be attached to the XML tree.
         */
        public void add_with_node(Xml.Node* node)

            requires(m_simulations != null)
            requires(node != null)
            requires(node->name == Simulation.ELEMENT_NAME)
            requires(node->parent != null)

        {
            Simulation simulation = Simulation.load(pixbufs, this, node);

            add_simulation(simulation);
        }



        private void add_simulation(Simulation simulation)
        {
            if (m_simulations.size > 0)
            {
                m_simulations.add(simulation);

                simulation.changed.connect(on_changed);
                simulation.inserted.connect(on_inserted);
                simulation.deleted.connect(on_deleted);
                simulation.toggled.connect(on_toggled);

                inserted(simulation);
                toggled(simulation);
                changed(this);
            }
            else
            {
                m_simulations.add(simulation);

                simulation.changed.connect(on_changed);
                simulation.inserted.connect(on_inserted);
                simulation.deleted.connect(on_deleted);
                simulation.toggled.connect(on_toggled);

                inserted(simulation);
                toggled(simulation);
                toggled(this);
                changed(this);
            }
        }


        /**
         * Create a new simulation and add it to this list.
         *
         * After creation, the simulation element must still be added to
         * the parent element.
         */
        public Simulation create_simulation(string subdir) throws Error
        {
            string simulation_dir = Path.build_filename(path, subdir);

            if (FileUtils.test(simulation_dir, FileTest.EXISTS))
            {
                string message = "Directory '%s' already exists".printf(simulation_dir);

                throw new ProjectError.UNABLE_TO_CREATE(message);
            }

            if (DirUtils.create_with_parents(simulation_dir, 0775) != 0)
            {
                string message = "Cannot create directory '%s'".printf(simulation_dir);

                throw new ProjectError.UNABLE_TO_CREATE(message);
            }

            Simulation simulation = Simulation.create(pixbufs, this, subdir);

            add_simulation(simulation);

            return simulation;
        }



        /**
         * Get the number of schematics in the container.
         */
        public override int get_child_count()

            requires(m_simulations != null)

        {
            return m_simulations.size;
        }



        /*
         *
         *
         */
        public override ProjectNode? get_child(int index)

            requires(m_simulations != null)
            requires(index >= 0)

        {
            return m_simulations.get(index);
        }



        public override bool get_child_index(ProjectNode child, out int index)

            requires(m_simulations != null)

        {
            // needs work

            index = m_simulations.index_of(child as Simulation);

            return false;
        }
    }
}
