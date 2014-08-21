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
     * A controller for manipulating projects.
     */
    public class ProjectController : GLib.Object
    {
        /**
         * The factory for creating dialog boxes
         */
        private DialogFactory m_factory;



        public SimpleAction action_project_new;
        public SimpleAction action_project_open;
        public SimpleAction action_project_save;

        public SimpleAction action_design_add;

        private Gtk.FileChooserDialog open_dialog;



        /**
         * Backing store for the project_list
         */
        private ProjectList? m_project_list;



        /**
         * The project list containing the project under control.
         */
        public ProjectList? project_list
        {
            get
            {
                return m_project_list;
            }
            set
            {
                if (m_project_list != null)
                {
                    m_project_list.notify.disconnect(this.on_notify);
                }

                m_project_list = value;

                if (m_project_list != null)
                {
                    m_project_list.notify.connect(this.on_notify);
                }
            }
        }



        /**
         * Create a new project controller.
         *
         *  param factory The factory for creating dialog boxes.
         *  param builder The builder containing actions for this controller.
         */
        public ProjectController(DialogFactory factory)

            ensures(action_design_add != null)
            ensures(action_project_new != null)
            ensures(action_project_open != null)
            ensures(action_project_save != null)

        {
            action_design_add = new SimpleAction("insert-new-design", null);
            action_design_add.activate.connect(on_design_add);

            action_project_new = new SimpleAction("file-new-project", null);
            action_project_new.activate.connect(on_project_new);

            action_project_open = new SimpleAction("file-open", null);
            action_project_open.activate.connect(on_project_open);

            action_project_save = new SimpleAction("file-save", null);
            action_project_save.activate.connect(on_project_save);

            m_factory = factory;

            open_dialog = null;

            /* initialize, then update to make sure actions get proper sensitivity */

            m_project_list = null;
            notify["project-list"].connect(on_notify);
            project_list = null;
        }



        /**
         * Create a dialog for opening a project.
         */
        private Gtk.FileChooserDialog get_open_dialog()
        {
            if (open_dialog == null)
            {
                open_dialog = new Gtk.FileChooserDialog(
                    "Open",
                    m_factory.Parent,
                    Gtk.FileChooserAction.OPEN,
                    Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL,
                    Gtk.Stock.OK,     Gtk.ResponseType.OK,
                    null
                    );
            }

            return open_dialog;
        }



        /**
         * Checks if the project is saved or closed.
         */
        public bool allow_program_exit()
        {
            try
            {
                Project? project = project_list.current;

                if ((project != null) && project_list.has_changes)
                {
                    Gtk.Dialog dialog = m_factory.create_confirm_save_dialog(project.filename);

                    try
                    {
                        switch (dialog.run())
                        {
                            case Gtk.ResponseType.OK:
                                project_list.save();
                                break;

                            case Gtk.ResponseType.REJECT:
                                break;

                            case Gtk.ResponseType.CANCEL:
                            case Gtk.ResponseType.DELETE_EVENT:
                                return false;

                            default:
                                assert_not_reached();
                                break;
                        }
                    }
                    finally
                    {
                        dialog.destroy();
                    }
                }

                return true;
            }
            catch (Error error)
            {
                Gtk.Dialog dialog = m_factory.create_unknown_error_dialog(error);

                dialog.run();
                dialog.destroy();
            }

            return false;
        }



        /**
         * Add a design to the project.
         */
        private void on_design_add(Variant? variant)

            requires(m_factory != null)
            requires(project_list != null)
            requires(project_list.current != null)

        {
            try
            {
                var dialog = new NewDesignDialog(project_list.current);

                dialog.set_transient_for(m_factory.Parent);

                int status = dialog.run();
                dialog.hide();

                if (status == Gtk.ResponseType.OK)
                {
                    project_list.current.create_design(
                        dialog.get_design_name(),
                        dialog.get_folder_name()
                        );
                }
            }
            catch (Error error)
            {
                Gtk.Dialog dialog = m_factory.create_unknown_error_dialog(error);

                dialog.run();
                dialog.destroy();
            }
        }



        /**
         * Responds to notify signals to update action sensitivity.
         *
         * This function responds to events generated by this and the
         * project_list.
         */
        private void on_notify(GLib.ParamSpec parameter)

            requires(action_project_save != null)

        {
            bool available = false;

            if (project_list != null)
            {
                available = (project_list.current != null);
            }

            action_design_add.set_enabled(available);
            action_project_save.set_enabled(available);
        }



        /**
         * Creates a new project
         */
        private void on_project_new(Variant? variant)

            requires(m_factory != null)
            requires(project_list != null)

        {
            try
            {
                Project? project = project_list.current;

                if ((project != null) && project_list.has_changes)
                {
                    Gtk.MessageDialog dialog = m_factory.create_confirm_save_dialog(project.filename);

                    try
                    {
                        switch (dialog.run())
                        {
                            case Gtk.ResponseType.OK:
                                project_list.save();
                                break;

                            case Gtk.ResponseType.REJECT:
                                break;

                            case Gtk.ResponseType.CANCEL:
                            case Gtk.ResponseType.DELETE_EVENT:
                                return;

                            default:
                                assert_not_reached();
                                break;
                        }
                    }
                    finally
                    {
                        dialog.destroy();
                    }
                }

                var dialog = new NewProjectDialog();

                dialog.set_transient_for(m_factory.Parent);

                try
                {
                    if (dialog.run() == Gtk.ResponseType.OK)
                    {
                        string filename = dialog.get_project_filename();
                        stdout.printf("Create filename %s", filename);
                        project_list.create(filename);
                    }
                }
                finally
                {
                    dialog.hide();
                }
            }
            catch (Error error)
            {
                Gtk.Dialog dialog = m_factory.create_unknown_error_dialog(error);

                dialog.run();
                dialog.destroy();
            }
        }



        /**
         * Opens a project
         */
        private void on_project_open(Variant? variant)

            requires(m_factory != null)
            requires(project_list != null)

        {
            try
            {
                Project? project = project_list.current;

                if ((project != null) && project_list.has_changes)
                {
                    Gtk.MessageDialog dialog = m_factory.create_confirm_save_dialog(project.filename);

                    try
                    {
                        switch (dialog.run())
                        {
                            case Gtk.ResponseType.OK:
                                project_list.save();
                                break;

                            case Gtk.ResponseType.REJECT:
                                break;

                            case Gtk.ResponseType.CANCEL:
                            case Gtk.ResponseType.DELETE_EVENT:
                                return;

                            default:
                                assert_not_reached();
                                break;
                        }
                    }
                    finally
                    {
                        dialog.destroy();
                    }
                }

                Gtk.FileChooserDialog dialog = get_open_dialog();

                try
                {
                    if (dialog.run() == Gtk.ResponseType.OK)
                    {
                        project_list.load(open_dialog.get_filename());
                    }
                }
                finally
                {
                    dialog.hide();
                }
            }
            catch (Error error)
            {
                Gtk.Dialog dialog = m_factory.create_unknown_error_dialog(error);

                dialog.run();
                dialog.destroy();
            }
        }



        /**
         * Saves the current project
         */
        private void on_project_save(Variant? variant)

            requires(m_factory != null)
            requires(project_list != null)

        {
            try
            {
                project_list.save();
            }
            catch (Error error)
            {
                Gtk.Dialog dialog = m_factory.create_unknown_error_dialog(error);

                dialog.run();
                dialog.destroy();
            }
        }
    }
}
