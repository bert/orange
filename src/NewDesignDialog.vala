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
 * A dialog box allowing the user to create a new design.
 *
 * Instances of this class must be constructed with Gtk.Builder. See
 * the extract() method.
 */
public class NewDesignDialog : Gtk.Dialog
{
    /**
     * The filename of the XML file containing the UI design.
     */
    public const string BUILDER_FILENAME = "NewDesignDialog.xml";



    /**
     * The entry widget containing the design name.
     */
    private Gtk.Entry m_design_name;



    /**
     * The entry widget containing the design folder name.
     */
    private Gtk.Entry m_folder_name;


    private Project m_project;

    private Gtk.ListStore m_type_list;

    private Gtk.TreeSelection m_type_selection;


    private Gtk.Widget m_error_design_exists;
    private Gtk.Widget m_error_folder_exists;

    private bool m_design_type_valid;
    private bool m_design_name_valid;
    private bool m_folder_name_valid;

    /*
     *
     */
    public static NewDesignDialog extract(Gtk.Builder builder, Project project)

        ensures(result.m_type_selection != null)

    {
        NewDesignDialog dialog = builder.get_object("dialog") as NewDesignDialog;

        dialog.m_project = project;

        dialog.m_design_name = builder.get_object("name-entry") as Gtk.Entry;
        dialog.m_design_name.notify["text"].connect(dialog.on_notify_design);

        dialog.m_folder_name = builder.get_object("folder-entry") as Gtk.Entry;
        dialog.m_folder_name.notify["text"].connect(dialog.on_notify_folder);

        dialog.m_type_list = builder.get_object("types-list") as Gtk.ListStore;

        Gtk.TreeView types_tree = builder.get_object("types-tree") as Gtk.TreeView;
        assert(types_tree != null);

        dialog.m_error_design_exists = builder.get_object("hbox-error-design-exists") as Gtk.Widget;
        dialog.m_error_folder_exists = builder.get_object("hbox-error-folder-exists") as Gtk.Widget;

        dialog.m_type_selection = types_tree.get_selection();
        dialog.m_type_selection.changed.connect(dialog.on_change);
        dialog.m_type_selection.set_mode(Gtk.SelectionMode.BROWSE);


        dialog.m_design_name.text = "Untitled";
        dialog.m_folder_name.text = dialog.m_design_name.text;


        return dialog;
    }



    public string get_design_name()

        requires(m_design_name != null)

    {
        return m_design_name.text;
    }



    public string get_folder_name()

        requires(m_folder_name != null)

    {
        return m_folder_name.text;
    }



    private void on_change()
    {
        stdout.printf("on_notify\n");
        stdout.flush();

        update();
    }




    private void on_notify_design(ParamSpec parameter)
    {
        if (m_design_name.text.length > 0)
        {
            bool design_exists = m_project.get_design(m_design_name.text) != null;

            m_error_design_exists.set_visible(design_exists);

            m_design_name_valid = !design_exists;
        }
        else
        {
            m_error_design_exists.set_visible(false);

            m_design_name_valid = false;
        }

        update();
    }



    private void on_notify_folder(ParamSpec parameter)
    {
        if (m_folder_name.text.length > 0)
        {
            string filename = m_project.get_project_subdir(m_folder_name.text);

            bool folder_exists = FileUtils.test(filename, FileTest.EXISTS);

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



    private void update()

        requires(m_design_name != null)
        requires(m_folder_name != null)
        requires(m_type_selection != null)

    {
        bool sensitive =
            (m_type_selection.count_selected_rows() == 1) &&
            (m_design_name_valid) &&
            (m_folder_name_valid);

        set_response_sensitive(Gtk.ResponseType.OK, sensitive);
    }
}
