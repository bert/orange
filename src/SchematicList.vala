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
/** brief A container for schematics in the project tree
 */
public class SchematicList : ProjectNode
{
    /*  A continer to store the list of schematics.
     */
    private Gee.ArrayList<Schematic> m_schematics;



    /** brief A name, visible to the user, for this node in the project tree.
     */
    public override string name
    {
        get
        {
            return "sch";
        }
    }






    public override string path
    {
        get
        {
            return parent.path;
        }
    }



    public Gee.List<Schematic> schematics
    {
        owned get
        {
            return m_schematics.read_only_view;
        }
    }


    /** brief Create a container for schematics
     *
     *  @param parent The parent node for this container.
     */
    private SchematicList(ProjectNode parent)
    {
        base(parent);
        m_schematics = new Gee.ArrayList<Schematic>();
    }



    /** @brief Add the schematic list to the batch operation.
     *
     *  Selecting the schematic list in the project tree is the
     *  same as selecting all the schematics within.
     */
    public override void add_to_batch(Batch batch)

        requires(m_schematics != null)

    {
        foreach (var schematic in m_schematics)
        {
            batch.add_schematic(schematic);
        }
    }


    /** brief Create a container for schematics
     *
     *  @param parent The parent node for this container.
     */
    public static SchematicList create(ProjectNode parent)
    {
        return new SchematicList(parent);
    }



    /** brief Add a schematic to the list
     *
     *  @param node The XML node representing the schematic. This node must
     *  be attached to the XML tree.
     */
    public void add_with_node(Xml.Node* node)

        requires(node != null)
        requires(node->name == Schematic.ELEMENT_NAME)
        requires(node->parent != null)

    {
        Schematic schematic = Schematic.load(this, node);

        m_schematics.add(schematic);

        schematic.changed.connect(on_changed);
        schematic.deleted.connect(on_deleted);
        schematic.inserted.connect(on_inserted);
        schematic.toggled.connect(on_toggled);

        inserted(schematic);
        changed(this);
    }



    /** brief Get the number of schematics in the container.
     */
    public override int get_child_count()
    {
        return m_schematics.size;
    }



    /** brief
     *
     *
     */
    public override ProjectNode? get_child(int index)

        requires(index >= 0)

    {
        return m_schematics.get(index);
    }



    public override bool get_child_index(ProjectNode child, out int index)
    {
        // needs work

        index = m_schematics.index_of(child as Schematic);

        return false;
    }
}
