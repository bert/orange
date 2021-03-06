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
     * A dialog box allowing the user add a simulation to an existing design.
     */
    public class AddSimulationDialog : Gtk.Dialog, Gtk.Buildable
    {
        /**
         * The resource name for the UI design.
         */
        public const string RESOURCE_NAME = "/org/geda-project/orange/AddSimulationDialog.xml";


        /**
         *
         */
        private const int BACKEND_COLUMN = 3;


        /**
         *
         */
        private const int ENGINE_COLUMN = 2;



        /**
         * The entry widget containing the simulation name.
         */
        private Gtk.Entry m_simulation_name;



        /**
         *
         */
        private Design m_design;



        /**
         *
         */
        private Gtk.ListStore m_type_list;



        /**
         *
         */
        private Gtk.TreeSelection m_type_selection;



        /**
         * A widget showing an error that the simulation name exists.
         */
        private Gtk.Widget m_error_name_exists;



        /**
         * A widget showing an error message that the simulation folder exists.
         */
        private Gtk.Widget m_error_folder_exists;



        /**
         *
         */
        private bool m_simulation_type_valid;



        /**
         *
         */
        private bool m_simulation_name_valid;


        private Gtk.TreeView types_tree;


        /**
         * Initialize the class.
         */
        class construct
        {
            set_template_from_resource(RESOURCE_NAME);
        }


        /**
         * Create the add simulation dialog.
         */
        public AddSimulationDialog(Design design)
        {
            init_template();

            m_design = design;

            m_simulation_name.notify["text"].connect(on_notify_name);

            assert(types_tree != null);

            m_type_selection = types_tree.get_selection();
            m_type_selection.changed.connect(on_change);
            m_type_selection.set_mode(Gtk.SelectionMode.BROWSE);

            m_simulation_name.text = "Untitled";
        }



        /**
         * Get the simulation backend selected by the user
         *
         *
         */
        public string get_simulation_backend()

            requires(m_type_selection != null)
            ensures(result != null)

        {
            Gtk.TreeIter iter;
            Gtk.TreeModel model;

            if (m_type_selection.get_selected(out model, out iter))
            {
                string backend = Simulation.DEFAULT_BACKEND;

                model.get(iter, BACKEND_COLUMN, ref backend);

                return backend;
            }

            return Simulation.DEFAULT_BACKEND;
        }



        /**
         * Get the simulation engine selected by the user
         *
         *
         */
        public string get_simulation_engine()

            requires(m_type_selection != null)
            ensures(result != null)

        {
            Gtk.TreeIter iter;
            Gtk.TreeModel model;

            if (m_type_selection.get_selected(out model, out iter))
            {
                string engine = Simulation.DEFAULT_ENGINE;

                model.get(iter, ENGINE_COLUMN, ref engine);

                return engine;
            }

            return Simulation.DEFAULT_ENGINE;
        }



        /**
         * Get the simulation name selected by the user
         *
         *
         */
        public string get_simulation_name()

            requires(m_simulation_name != null)

        {
            return m_simulation_name.text;
        }



        /**
         * Event handler when the simulation type is changed
         */
        private void on_change()

            requires(m_type_selection != null)

        {
            m_simulation_type_valid = (m_type_selection.count_selected_rows() == 1);

            update();
        }



        /**
         * Event handler when the simulation name is changed
         */
        private void on_notify_name(ParamSpec parameter)

            requires(m_design != null)
            requires(m_simulation_name != null)

        {
            if (m_simulation_name.text.length > 0)
            {
                bool name_exists = m_design.get_simulation(m_simulation_name.text) != null;

                m_error_name_exists.set_visible(name_exists);

                string filename = Path.build_filename(
                    m_design.simulation_list.path,
                    m_simulation_name.text
                    );

                bool subdir_exists = FileUtils.test(filename, FileTest.EXISTS);

                m_error_folder_exists.set_visible(subdir_exists);

                m_simulation_name_valid = !subdir_exists && !name_exists;
            }
            else
            {
                m_error_folder_exists.set_visible(false);
                m_error_name_exists.set_visible(false);

                m_simulation_name_valid = false;
            }

            update();
        }



        /**
         * Update the sensitivity of the dialog buttons
         */
        private void update()
        {
            bool sensitive = m_simulation_type_valid && m_simulation_name_valid;

            set_response_sensitive(Gtk.ResponseType.OK, sensitive);
        }


        /**
         * Couldn't get the template bindings to work, so this function
         * obtains the objects from the Gtk.Builder.
         */
        private void parser_finished(Gtk.Builder builder)
        {
            m_simulation_name = builder.get_object("name-entry") as Gtk.Entry;
            m_type_list = builder.get_object("types-list") as Gtk.ListStore;
            types_tree = builder.get_object("types-tree") as Gtk.TreeView;
            m_error_folder_exists = builder.get_object("hbox-error-folder-exists") as Gtk.Widget;
            m_error_name_exists = builder.get_object("hbox-error-design-exists") as Gtk.Widget;
        }
    }
}
