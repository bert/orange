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
/** @brief A batch operation to export prints in the project tree.
 */
public class ExportPrintBatch : Batch
{
    /** @brief The default output filename.
     */
    private const string DEFAULT_PRINT_FILENAME = "output.pdf";



    /** @brief The command line application to print schematics.
     */
    private const string PRINT_SCHEMATIC_COMMAND = "gaf";



    /** @brief The command line application to print schematics.
     */
    private const string PRINT_SCHEMATIC_SUBCOMMAND = "export";



    /** @brief A set of all the schematics in the batch operation.
     *
     *  The operation uses a set to eliminate duplicates.
     */
    private Gee.HashSet<Schematic> m_schematics;



    /** @brief Create a new, empty batch operation.
     */
    public ExportPrintBatch(DialogFactory factory, Gtk.Action action)
    {
        base(factory, action);

        m_schematics = new Gee.HashSet<Schematic>();

        update();
    }



    /** @brief Add a schematic to the batch operation.
     */
    public override void add_schematic(Schematic schematic)
    {
        m_schematics.add(schematic);
    }



    /** @brief Clear all nodes from the batch operation.
     */
    public override void clear()
    {
        m_schematics.clear();
    }



    /** @brief Determines if the current batch is editable.
     */
    public override bool enabled()
    {
        return (m_schematics.size > 0);
    }



    /** @brief Run the batch operation.
     */
    public override void run() throws Error
    {
        var designs = new Gee.HashSet<Design>();

        foreach (var schematic in m_schematics)
        {
            designs.add(schematic.design);
        }

        foreach (var design in designs)
        {
            string dirname = design.create_print_subdir();

            var dialog = create_save_dialog(dirname);

            int status = dialog.run();
            dialog.hide();

            if (status == Gtk.ResponseType.CANCEL)
            {
                continue;
            }

            create_print_file(design, dialog.get_filename());
        }
    }



    private Gtk.FileChooserDialog create_save_dialog(string dirname)
    {
        var dialog = new Gtk.FileChooserDialog(
            "Export PDF Schematic",
            m_factory.Parent,
            Gtk.FileChooserAction.SAVE,
            Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL,
            Gtk.Stock.OK,     Gtk.ResponseType.OK,
            null
            );

        dialog.do_overwrite_confirmation = true;

        dialog.set_current_folder(dirname);
        dialog.set_current_name(DEFAULT_PRINT_FILENAME);

        return dialog;
    }



    private void create_print_file(Design design, string filename) throws Error
    {
        var arguments = new Gee.ArrayList<string>();

        arguments.add(PRINT_SCHEMATIC_COMMAND);
        arguments.add(PRINT_SCHEMATIC_SUBCOMMAND);

        arguments.add("-o");
        arguments.add(filename);

        foreach (Schematic schematic in design.schematics)
        {
            if (schematic in m_schematics)
            {
                arguments.add(schematic.basename);
            }
        }

        arguments.add(null);

        int status;

        Process.spawn_sync(
            design.path,
            arguments.to_array(),
            null,
            SpawnFlags.SEARCH_PATH,
            null,
            null,
            null,
            out status
            );

        if (status != 0)
        {
            // throw something
        }
    }
}
