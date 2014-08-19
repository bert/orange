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
     * A dialog box allowing the user to archive the schematics in the design.
     */
    public class ArchiveSchematicsDialog : Gtk.FileChooserDialog
    {
        /**
         * The resource name for the UI design.
         */
        public const string RESOURCE_NAME = "/org/geda-project/orange/ArchiveSchematicsDialog.xml";


        /**
         * Initialize the class.
         */
        class construct
        {
            set_template_from_resource(RESOURCE_NAME);
        }


        /**
         * Create the archive schematics dialog.
         */
        public ArchiveSchematicsDialog()
        {
            init_template();
        }
    }
}
