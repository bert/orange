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
/** @brief A batch operation to export BOMs in the project tree.
 */
public class ExportBOMBatch : Batch
{
    /** @brief The default output filename.
     */
    private const string DEFAULT_BOM_FILENAME = "output.bom";



    /** @brief The command line application to generate netlists.
     */
    private const string NETLIST_COMMAND = "gnetlist";



    /** @brief A set of all the designs in the batch operation.
     *
     *  The operation uses a set to eliminate duplicates.
     */
    private Gee.HashSet<Design> m_designs;



    /** @brief Create a new, empty batch operation.
     */
    public ExportBOMBatch(DialogFactory factory, Gtk.Action action)
    {
        base(factory, action);

        m_designs = new Gee.HashSet<Design>();

        update();
    }



    /** @brief Add a schematic to the batch operation.
     */
    public override void add_design(Design design)
    {
        m_designs.add(design);
    }



    /** @brief Clear all nodes from the batch operation.
     */
    public override void clear()
    {
        m_designs.clear();
    }



    /** @brief Determines if the current batch is editable.
     */
    public override bool enabled()
    {
        return (m_designs.size > 0);
    }



    /** @brief Run the batch operation.
     */
    public override void run() throws Error
    {
        foreach (var design in m_designs)
        {
            string dirname = design.create_bom_subdir();

            var dialog = m_factory.create_export_bom_dialog();

            dialog.set_current_folder(dirname);
            dialog.set_current_name(DEFAULT_BOM_FILENAME);

            int status = dialog.run();
            dialog.hide();

            if (status == Gtk.ResponseType.CANCEL)
            {
                continue;
            }

            create_bom_file(
                design,
                dialog.get_filename(),
                dialog.get_bom_format()
                );
        }
    }



    private void create_bom_file(Design design, string filename, string format) throws Error
    {
        var arguments = new Gee.ArrayList<string>();

        arguments.add(NETLIST_COMMAND);

        arguments.add("-o");
        arguments.add(filename);

        arguments.add("-g");
        arguments.add(format);

        foreach (Schematic schematic in design.schematics)
        {
            arguments.add(schematic.basename);
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
