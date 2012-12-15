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
 * A dialog box allowing the user to archive the schematics in the design.
 *
 * Instances of this class must be constructed with Gtk.Builder.
 */
public class ArchiveSchematicsDialog : Gtk.FileChooserDialog
{
    /**
     * The filename of the XML file containing the UI design.
     */
    public const string BUILDER_FILENAME = "ArchiveSchematicsDialog.xml";



    /**
     * Extract references to the dialog from Gtk.Builder
     */
    public static ArchiveSchematicsDialog extract(Gtk.Builder builder)

        ensures(result != null)

    {
        ArchiveSchematicsDialog dialog = builder.get_object("dialog") as ArchiveSchematicsDialog;

        return dialog;
    }
}
