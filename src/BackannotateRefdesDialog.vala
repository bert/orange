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
     * A dialog box allowing the user to create a new design.
     *
     * Instances of this class must be constructed with Gtk.Builder.
     */
    public class BackannotateRefdesDialog : Gtk.FileChooserDialog
    {
        /**
         * The filename of the XML file containing the UI design.
         */
        public const string BUILDER_FILENAME = "BackannotateRefdesDialog.xml";



        /**
         * The combo box containing the netlist format.
         */
        private Gtk.ComboBox m_combo;


        private Gtk.ListStore m_formats;


        /*
         *
         */
        public static BackannotateRefdesDialog extract(Gtk.Builder builder)
        {
            BackannotateRefdesDialog dialog = builder.get_object("dialog") as BackannotateRefdesDialog;

            dialog.m_combo = builder.get_object("format-combo") as Gtk.ComboBox;
            dialog.m_formats = builder.get_object("netlist-formats") as Gtk.ListStore;

            return dialog;
        }


        /**
         * Get the netlist format
         */
        public string? get_netlist_format()
        {
            Gtk.TreeIter iter;

            if (m_combo.get_active_iter(out iter))
            {
                GLib.Value value;

                m_formats.get_value(iter, 0, out value);

                return value.get_string();
            }

            return null;
        }
    }
}
