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
 * A dialog box allowing the user to renumber the REFDES on a design.
 *
 * Instances of this class must be constructed with Gtk.Builder.
 */
public class RenumberRefdesDialog : Gtk.Dialog
{
    /**
     * The filename of the XML file containing the UI design.
     */
    public const string BUILDER_FILENAME = "RenumberRefdesDialog.xml";



    /**
     * The Gtk.CheckButton that controls forcing renumbering all components
     */
    public Gtk.CheckButton m_force_check;



    /**
     * The Gtk.CheckButton that includes page numbers in the REFDES
     */
    public Gtk.CheckButton m_digits_check;



    /**
     * The Gtk.CheckButton that contains the number of digits to use for the
     * component number.
     */
    public Gtk.SpinButton m_digits_spin;



    /**
     * Extract references to the dialog from Gtk.Builder
     */
    public static RenumberRefdesDialog extract(Gtk.Builder builder)
    {
        RenumberRefdesDialog dialog = builder.get_object("dialog") as RenumberRefdesDialog;

        dialog.m_digits_check = builder.get_object("check-digits") as Gtk.CheckButton;
        dialog.m_digits_spin = builder.get_object("spin-digits") as Gtk.SpinButton;
        dialog.m_force_check = builder.get_object("check-force") as Gtk.CheckButton;

        dialog.m_digits_spin.adjustment.lower = 2;
        dialog.m_digits_spin.adjustment.upper = 5;
        dialog.m_digits_spin.adjustment.step_increment = 1;
        dialog.m_digits_spin.adjustment.value = 2;

        dialog.m_digits_check.notify["active"].connect(dialog.on_notify_active);
        dialog.m_digits_check.active = false;

        dialog.m_digits_spin.sensitive = false;

        return dialog;
    }



    /**
     * Force renumbering of all components.
     */
    public bool get_force_renumber()
    {
        return m_force_check.active;
    }



    /**
     * The multiplier for the page number to add to the component number.
     */
    public string get_page_number_param()
    {
        return "%.0f".printf(Math.exp10(m_digits_spin.get_value()));
    }



    /**
     * Include page numbers in the REFDES.
     */
    public bool get_include_page_numbers()
    {
        return m_digits_check.active;
    }



    private void on_notify_active()
    {
        m_digits_spin.sensitive = m_digits_check.active;
    }
}
