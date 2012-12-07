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
/*
 *
 *
 *
 *
 */
public class Design : ProjectNode
{
    /**
     *  The subdirectory in the project to store exported BOMs.
     */
    private const string BOM_SUBDIR = "bom";



    /**
     *  The name of the XML element for the design
     */
    private const string ELEMENT_NAME = "Design";



    /**
     *  The subdirectory in the project to store exported netlists.
     */
    private const string NETLIST_SUBDIR = "net";



    /**
     *  The subdirectory in the project to store exported schematics.
     */
    private const string PRINT_SUBDIR = "pdf";



    /**
     *  The name of the XML attribute for the id
     */
    private const string PROP_NAME_ID = "id";



    /**
     *  The name of the XML attribute for the basename
     */
    private const string PROP_NAME_BASENAME = "file";



    private string m_name;
    private ProjectNode m_parent;
    private Gee.ArrayList<ProjectNode> m_children;


    private string m_path;

    private string m_basename;



    public Xml.Node* element
    {
        get;
        private set;
    }



    /*
     *
     *
     *
     */
    public override string name
    {
        get
        {
            return m_name = element->get_prop(PROP_NAME_ID);
        }
    }



    public string basename
    {
        get
        {
            return m_basename = element->get_prop(PROP_NAME_BASENAME);;
        }
    }


    public override string path
    {
        get
        {
            return m_path = Path.build_filename(
                parent.path,
                basename,
                null
                );
        }
    }




    public override Design? design
    {
        get
        {
            return this;
        }
    }



    /**
     *  A read only view of the schematics in this design.
     */
    public Gee.List<Schematic> schematics
    {
        owned get
        {
            return schematic_list.schematics;
        }
    }



    public SchematicList schematic_list
    {
        get;
        private set;
    }



    /**
     *  Create a new design
     *
     *  param parent
     *  param element
     */
    private Design(ProjectNode parent, Xml.Node *element)

        requires(element != null)
        requires(element->type == Xml.ElementType.ELEMENT_NODE)
        requires(element->name == ELEMENT_NAME)
        requires(element->get_prop(PROP_NAME_BASENAME) != null)

    {
        base(parent);

        m_parent = parent;
        this.element = element;

        schematic_list = SchematicList.create(this);

        m_children = new Gee.ArrayList<ProjectNode>();

        add(schematic_list);
    }



    /**
     *  Creates a new design
     *
     *  The newly created design must be added to the list of children in the
     *  parent project. Similarly, the XML node for the newly created design
     *  must be added as a child to the XML node for the parent project.
     *
     *  param parent The parent project.
     *  param name The name of the design as it appears to the user.
     *  param subdir The subdirectory to store the design files
     *  return The created design.
     */
    public static Design create(ProjectNode parent, string name, string subdir)
    {
        Xml.Node* element = new Xml.Node(null, ELEMENT_NAME);

        element->set_prop(PROP_NAME_ID, name);

        element->set_prop(PROP_NAME_BASENAME, subdir);

        return new Design(parent, element);
    }



    /**
     *  Load a design from an XML node.
     *
     *  The newly loaded design must be added to the list of children in the
     *  parent project.
     *
     *  param parent The parent project.
     *  param element The XML node for the design.
     *  return The loaded design.
     */
    public static Design load(ProjectNode parent, Xml.Node *element) throws Error

        requires(element != null)
        requires(element->type == Xml.ElementType.ELEMENT_NODE)
        requires(element->name == ELEMENT_NAME)

    {
        if (element->get_prop(PROP_NAME_BASENAME) == null)
        {
            throw new ProjectError.UNABLE_TO_LOAD("Design node does not have a basename.");
        }

        Design design = new Design(parent, element);

        Xml.Node* child = element->children;

        while (child != null)
        {
            if (child->type != Xml.ElementType.ELEMENT_NODE)
            {
                child = child->next;
                continue;
            }

            if (child->name == Schematic.ELEMENT_NAME)
            {
                design.schematic_list.add_with_node(child);
            }

            child = child->next;
        }

        return design;
    }



    /**
     *  Add and existing schematic to this design.
     *
     *  param filename The absolute path to the schematic file.
     */
    public void add_existing_schematic(string filename) throws Error
    {
        File schematic_filename = File.new_for_path(filename);

        File design_filename = File.new_for_path(path);

        string? relative = design_filename.get_relative_path(schematic_filename);

        if (relative == null)
        {
            // throw something;
            return;
        }

        Xml.Node* schematic_element = Schematic.create(relative);

        if (schematic_element == null)
        {
            // throw something;
            return;
        }

        element->add_child(schematic_element);
        schematic_list.add_with_node(schematic_element);
    }



    /**
     *  Add this design to a batch operation.
     */
    public override void add_to_batch(Batch batch)
    {
        batch.add_design(this);
    }



    /**
     *  Create the subdirectory for storing schematics
     *
     *  return The path to the subdirectory for storing schematics
     */
    public string create_bom_subdir() throws Error
    {
        string dirname = Path.build_filename(path, BOM_SUBDIR);

        int status = DirUtils.create(dirname, 0775);

        if (status != 0)
        {
            // throw something
        }

        return dirname;
    }



    /**
     *  Create the subdirectory for storing schematics
     *
     *  return The path to the subdirectory for storing schematics
     */
    public string create_netlist_subdir() throws Error
    {
        string dirname = Path.build_filename(path, NETLIST_SUBDIR);

        int status = DirUtils.create(dirname, 0775);

        if (status != 0)
        {
            // throw something
        }

        return dirname;
    }



    /**
     *  Create the subdirectory for storing schematics
     *
     *  return The path to the subdirectory for storing schematics
     */
    public string create_print_subdir() throws Error
    {
        string dirname = Path.build_filename(path, PRINT_SUBDIR);

        int status = DirUtils.create(dirname, 0775);

        if (status != 0)
        {
            // throw something
        }

        return dirname;
    }






    /*
     *
     *
     *
     */
    public override ProjectNode? get_child(int index)
    {
        return m_children.get(index);
    }



    /*
     *
     *
     *
     */
    public override int get_child_count()
    {
        return m_children.size;
    }



    /*
     *
     *
     *
     */
    public override bool get_child_index(ProjectNode node, out int index)
    {
        bool success = m_children.contains(node);

        index = m_children.index_of(node);

        return success;
    }



    /*
     *
     *
     *
     */
    private void add(ProjectNode node)
    {
        node.changed.connect(on_changed);
        node.deleted.connect(on_deleted);
        node.inserted.connect(on_inserted);
        node.toggled.connect(on_toggled);

        m_children.add(node);
    }
}
