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
     *
     */
    public class MainWindow : Gtk.ApplicationWindow
    {
        /**
         * The XML builder file used to construct the main UI.
         */
        private const string BUILDER_FILENAME = "MainWindow.xml";



        /**
         * The name of the program as it appears in the title bar.
         */
        [CCode(cname = "PACKAGE_NAME")]
        private static extern const string PROGRAM_TITLE;



        /**
         * The name of an untitled document as it appears in the title bar.
         */
        private const string UNTITLED_NAME = "Untitled";



        /**
         * The context menu for the project view wiget.
         */
        private Gtk.Menu m_context_menu;



        /**
         * A controller for common operations.
         *
         * The batch controller handles common operations on groups of project
         * nodes. Common operations include edit, print, etc...
         */
        private BatchController m_batch_controller;



        private Gtk.Dialog m_help_about;



        /**
         * A controller to handle operations on the project.
         *
         * The project controller handles operations such as new,
         * load, save, etc...
         */
        private ProjectController m_project_controller;



        /**
         * A list of the (0 or 1) projects loaded.
         *
         * This object persists across creation and destruction of projects
         * and provides signals to the application for changes in the
         * project state.
         */
        private ProjectList m_project_list;



        /**
         * The TreeModel for the project list.
         */
        private ProjectTreeModel m_project_model;



        /**
         * The TreeView for the project list.
         */
        private Gtk.TreeView m_project_view;



        /**
         * Construct the program
         */
        public MainWindow()
        {
        }


        public static MainWindow? create(File? file = null)
        {
            try
            {
                stdout.printf("Registering %s\n", typeof(MainWindow).name());

                Gtk.Builder builder = new Gtk.Builder();
                builder.add_from_file(Path.build_filename(
                    DialogFactory.PKGDATADIR,
                    DialogFactory.XML_SUBDIR,
                    BUILDER_FILENAME
                    ));

                var window = builder.get_object("main") as MainWindow;

                window.m_project_list = new ProjectList(window);
                window.m_project_list.notify.connect(window.on_notify);
                window.m_project_list.notify["current"].connect(window.on_notify_current);

                (builder.get_object("file-quit") as Gtk.Action).activate.connect(window.on_action_quit);

                DialogFactory factory = new DialogFactory(window);

                window.m_project_controller = new ProjectController(factory, builder);
                window.m_project_controller.project_list = window.m_project_list;
                window.m_project_controller.notify.connect(window.on_notify);

                window.m_batch_controller = new BatchController(factory, builder);

                window.m_project_model = new ProjectTreeModel(window.m_project_list);

                window.m_project_view = builder.get_object("main-project-tree") as Gtk.TreeView;
                window.m_project_view.set_model(window.m_project_model);
                window.m_project_view.get_selection().changed.connect(window.on_selection_change);

                /* For the context menu */
                Gtk.UIManager uimanager = builder.get_object("uimanager") as Gtk.UIManager;
                window.m_context_menu = uimanager.get_widget("ui/context-menu") as Gtk.Menu;
                //Gdk.EventMask event_mask = m_project_view.window.get_events();
                //event_mask |= Gdk.EventMask.BUTTON_PRESS_MASK;
                //m_project_view.window.set_events(event_mask);
                window.m_project_view.button_press_event.connect(window.on_button_press);

                window.m_help_about = factory.create_about_dialog();
                (builder.get_object("help-about") as Gtk.Action).activate.connect(window.on_help_about);

                window.delete_event.connect(window.on_delete_event);
                window.destroy.connect(Gtk.main_quit);

                if (file != null)
                {
                    window.m_project_list.load(file.get_path());
                }

                return window;
            }
            catch (Error error)
            {
                stderr.printf("%s\n", error.message);
            }

            return null;
        }


        /**
         * An event handler when the user selects quit from the menu.
         */
        private void on_action_quit(Gtk.Action sender)

            requires(m_project_controller != null)

        {
            if (m_project_controller.allow_program_exit())
            {
                this.destroy();
            }
        }



        /**
         * An event handler for when the user presses a button in the project view
         *
         *
         */
        private bool on_button_press(Gdk.EventButton event)

            requires(m_context_menu != null)

        {
            if ((event.type == Gdk.EventType.BUTTON_PRESS) && (event.button == 3))
            {
                stdout.printf("on_button_press\n");

                m_context_menu.popup(null, null, null, event.button, event.time);
            }

            return false;
        }



        /**
         * An event handler when the user selects the delete button.
         *
         * return true Abort the destruction process
         * return false Continue with the destruction process
         */
        private bool on_delete_event(Gdk.EventAny event)

            requires(m_project_controller != null)

        {
            return !m_project_controller.allow_program_exit();
        }



        /**
         * An event handler for the about dialog
         */
        private void on_help_about()

            requires(m_help_about != null)

        {
            m_help_about.run();
            m_help_about.hide();
        }

        /**
         * An event handler to respond to selection changes.
         *
         * This event handler responds to changes in selected project nodes
         * and updates the controllers with the new selection. The controllers
         * update the user interface, such as changing the sensitivity of the
         * buttons.
         */
        private void on_selection_change()

            requires(m_batch_controller != null)
            requires(m_project_model != null)
            requires(m_project_view != null)

        {
            List<Gtk.TreePath> paths = m_project_view.get_selection().get_selected_rows(null);

            List<ProjectNode> nodes = m_project_model.convert(paths);

            m_batch_controller.set_selection(nodes);
        }



        /**
         * Update the projet name in the titlebar
         */
        private void on_notify(ParamSpec parameter)

            requires(m_project_list != null)
            requires(m_project_view != null)

        {

            Project current = m_project_list.current;

            if (current == null)
            {
                this.set_title(PROGRAM_TITLE);
            }
            else
            {
                string modified = m_project_list.has_changes ? "*" : "";

                string filename = current.filename;

                if (filename == null)
                {
                    this.set_title("%s%s - %s".printf(UNTITLED_NAME, modified, PROGRAM_TITLE));
                }
                else
                {
                    this.set_title("%s%s - %s".printf(Path.get_basename(filename), modified, PROGRAM_TITLE));
                }
            }
        }



        /**
         * An event handler for project change notifications.
         *
         * Expands the root project node so the user can see all the designs.
         */
        private void on_notify_current(ParamSpec parameter)

            requires(m_project_list != null)
            requires(m_project_view != null)

        {
            Project current = m_project_list.current;

            if (current != null)
            {
                m_project_view.expand_row(new Gtk.TreePath.first(), false);
            }
        }
    }
}
