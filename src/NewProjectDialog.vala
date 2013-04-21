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
 * A dialog box allowing the user to create a new project.
 *
 * Instances of this class must be constructed with Gtk.Builder. To complete
 * construction and create a vaild state, the extract() function must be used.
 */
public class NewProjectDialog : Gtk.Dialog
{
    /**
     * The filename of the XML file containing the UI design.
     */
    public const string BUILDER_FILENAME = "NewProjectDialog.xml";



    /**
     * The filename extension for project files
     */
    public const string DEFAULT_PROJECT_NAME = "untitled";



    /**
     * The filename extension for project files
     */
    public const string FILENAME_EXTENSION = ".xml";



    /**
     * A widget showing the project folder already exists.
     *
     * Making this widget visible will indicate to the user that the
     * current project folder already exists.
     */
    private Gtk.Widget m_error_folder_exists;



    /**
     * The folder chooser widget containing the parent folder.
     */
    private Gtk.FileChooserWidget m_folder_chooser;



    /**
     * The entry widget containing the design name.
     */
    private Gtk.Entry m_project_name;



    /**
     * Indicates the project name is valid.
     */
    private bool m_project_name_valid;



    /**
     * The entry widget containing the design folder name.
     */
    private Gtk.Entry m_folder_name;



    /**
     * Indicates the folder name is valid.
     *
     * This boolean value is updated after every change to the text
     * inside the folder widget.
     */
    private bool m_folder_name_valid;



    /**
     * Extract and initialize the dialog from XML builder.
     *
     *  TODO: need to throw exceptions if the dialog does not initialize correctly.
     */
    public static NewProjectDialog extract(Gtk.Builder builder) throws Error

        ensures(result.m_folder_chooser != null)
        ensures(result.m_folder_name != null)
        ensures(result.m_project_name != null)

    {
        NewProjectDialog dialog = builder.get_object("dialog") as NewProjectDialog;

        dialog.m_folder_chooser = builder.get_object("folder-chooser") as Gtk.FileChooserWidget;
        dialog.m_folder_chooser.selection_changed.connect(dialog.on_selection_change);

        dialog.m_folder_name = builder.get_object("folder-entry") as Gtk.Entry;
        dialog.m_folder_name.notify["text"].connect(dialog.on_notify_folder);

        dialog.m_project_name = builder.get_object("name-entry") as Gtk.Entry;
        dialog.m_project_name.notify["text"].connect(dialog.on_notify_name);

        dialog.m_error_folder_exists = builder.get_object("hbox-error-folder-exists") as Gtk.Widget;

        /* set up initial values */

        dialog.m_folder_chooser.set_filename(
            Environment.get_current_dir()
            );

        dialog.m_project_name.text = DEFAULT_PROJECT_NAME;

        return dialog;
    }



    /**
     * Gets the project filename
     */
    public string get_project_filename()

        requires(m_folder_chooser != null)
        requires(m_folder_name != null)
        requires(m_project_name != null)
        ensures(result != null)

    {
        return GLib.Path.build_filename(
            m_folder_name.text,
            m_project_name.text + FILENAME_EXTENSION,
            null
            );

    }


    /**
     * Handles when the project name changes.
     */
    private void on_notify_folder()

        requires(m_folder_chooser != null)
        requires(m_folder_name != null)
        requires(m_project_name != null)

    {
        if (m_folder_name.text.length > 0)
        {
            bool folder_exists = FileUtils.test(m_folder_name.text, FileTest.EXISTS);

            m_error_folder_exists.set_visible(folder_exists);

            m_folder_name_valid = !folder_exists;
        }
        else
        {
            m_error_folder_exists.set_visible(false);

            m_folder_name_valid = false;
        }

        update();
    }



    /**
     * Handles when the project name changes.
     */
    private void on_notify_name()

        requires(m_folder_chooser != null)
        requires(m_folder_name != null)
        requires(m_project_name != null)

    {
        m_folder_name.text = GLib.Path.build_filename(
            m_folder_chooser.get_filename(),
            m_project_name.text,
            null
            );

        m_project_name_valid = (m_project_name.text.length > 0);

        update();
    }



    /**
     * Handles when the parent folder changes.
     */
    private void on_selection_change()

        requires(m_folder_chooser != null)
        requires(m_folder_name != null)
        requires(m_project_name != null)

    {
        m_folder_name.text = GLib.Path.build_filename(
            m_folder_chooser.get_filename(),
            m_project_name.text,
            null
            );

        update();
    }



    /**
     * Updates the sensitivity of the ok button.
     */
    private void update()
    {
        set_response_sensitive(Gtk.ResponseType.OK, m_project_name_valid && m_folder_name_valid);
    }
}
