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
    public class MainWindow : Gtk.ApplicationWindow, Gtk.Buildable
    {
        /**
         * The resource name for the UI design.
         */
        public const string RESOURCE_NAME = "/org/geda-project/orange/MainWindow.xml";



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



        private Gtk.Dialog about_dialog;



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
         * Initialize the class.
         */
        class construct
        {
            set_template_from_resource(RESOURCE_NAME);
        }


        /**
         * Construct the main window.
         */
        public MainWindow(File? file = null)
        {
            init_template();

            SimpleAction action;

            action = new SimpleAction("file-close", null);
            action.activate.connect(on_action_close);
            add_action(action);

            action = new SimpleAction("file-quit", null);
            action.activate.connect(on_action_quit);
            add_action(action);

            action = new SimpleAction("help-about", null);
            action.activate.connect(on_help_about);
            add_action(action);

            DialogFactory factory = new DialogFactory(this);

            m_project_controller = new ProjectController(factory);
            m_batch_controller = new BatchController(factory);

            m_project_list = new ProjectList(this);
            m_project_list.notify.connect(on_notify);
            m_project_list.notify["current"].connect(on_notify_current);

            m_project_controller.project_list = m_project_list;
            m_project_controller.notify.connect(on_notify);

            m_project_model = new ProjectTreeModel(m_project_list);

            m_project_view.set_model(m_project_model);
            m_project_view.get_selection().changed.connect(on_selection_change);

            m_project_view.button_press_event.connect(on_button_press);

            delete_event.connect(on_delete_event);

            foreach (var batch in m_batch_controller.batches)
            {
                add_action(batch.action);
            }

            add_action(m_project_controller.action_project_new);
            add_action(m_project_controller.action_project_open);
            add_action(m_project_controller.action_project_save);
            add_action(m_project_controller.action_design_add);

            if (file != null)
            {
                try
                {
                    m_project_list.load(file.get_path());
                }
                catch (Error error)
                {
                    stderr.printf("%s\n", error.message);
                }
            }
        }


        /**
         * @brief An event handler when the user closes the window
         */
        private void on_action_close(Variant? variant)
        {
            this.close();
        }



        /**
         * @brief An event handler when the user quits the application
         */
        private void on_action_quit(Variant? variant)
        {
            /** @todo figure out how to close all windows
             *
             *  The save confirmation dialog aborts closing the app, but it
             *  behaves the same way as the Gnome version from the application
             *  menu.
             */

            foreach (var window in application.get_windows())
            {
                window.close();
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
         * @brief An event handler when the user selects the delete button.
         *
         * @retval true Abort the destruction process
         * @retval false Continue with the destruction process
         */
        private bool on_delete_event(Gdk.EventAny event)

            requires(m_project_controller != null)

        {
            return !m_project_controller.allow_program_exit();
        }


        /**
         * An event handler for the about dialog
         */
        private void on_help_about(Variant? variant)
        {
            if (about_dialog == null)
            {
                about_dialog = new AboutDialog();
                about_dialog.set_transient_for(this);
            }

            about_dialog.run();
            about_dialog.hide();
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



        /**
         * Couldn't get the template bindings to work, so this function
         * obtains the objects from the Gtk.Builder.
         */
        private void parser_finished(Gtk.Builder builder)
        {
            var popup_model = builder.get_object("popup-menu") as MenuModel;
            m_context_menu = new Gtk.Menu.from_model(popup_model);

            m_project_view = builder.get_object("main-project-tree") as Gtk.TreeView;
        }
    }
}
