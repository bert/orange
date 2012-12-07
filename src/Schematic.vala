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
 *
 *
 *
 *
 */
public class Schematic : ProjectNode
{
    public const string ELEMENT_NAME = "sch";

    private const string PROP_NAME_BASENAME = "file";


    private string m_basename;
    private string m_filename;



    /** brief
     *
     *
     *
     */
    public Xml.Node* element
    {
        get;
        private set;
    }



    /** brief The name of the node
     *
     *  For schematics, the basename of the file is used as the name.
     */
    public override string name
    {
        get
        {
            return basename;
        }
    }



    /** @brief The basename for this schematic file.
     */
    public string basename
    {
        get
        {
            return m_basename = element->get_prop(PROP_NAME_BASENAME);
        }
    }



    /** brief The dirname for this schematic
     *
     */
    public override string path
    {
        get
        {
            return parent.path;
        }
    }



    /** brief The filename of this schematic
     *
     */
    public string filename
    {
        get
        {
            return m_filename = Path.build_filename(
                path,
                basename,
                null
                );
        }
    }



    /** brief
     *
     *
     *
     */
    private Schematic(ProjectNode parent, Xml.Node* element)

        requires(element != null)

    {
        base(parent);
        this.element = element;
    }



    public override void add_to_batch(Batch batch)
    {
        batch.add_schematic(this);
    }



    /** @brief
     *
     *
     *
     */
    public static Xml.Node* create(string filename)
    {
        Xml.Node* element = new Xml.Node(null, ELEMENT_NAME);

        element->set_prop(PROP_NAME_BASENAME, filename);

        return element;
    }



    /** brief
     *
     *
     *
     */
    public static Schematic load(ProjectNode parent, Xml.Node* element)

        requires(element != null)

    {
        return new Schematic(parent, element);
    }



    /** brief
     *
     *  The schematic has no child nodes, so this function returns 0.
     *
     */
    public override int get_child_count()
    {
        return 0;
    }



    /** brief
     *
     *  The schematic has no child nodes, so this function returns null.
     *
     */
    public override ProjectNode? get_child(int index)
    {
        return null;
    }



    /** brief
     *
     *  The schematic has no child nodes, so this function returns false.
     *
     */
    public override bool get_child_index(ProjectNode child, out int index)
    {
        index = 0;
        return false;
    }
}
