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
public class Project : ProjectNode
{
    private const string PROJECT_NAME = "Project";

    private string m_name;
    private string m_path;
    private string m_filename;

    private Xml.Doc* document;

    public Xml.Node* element
    {
        get;
        set;
    }



    public override Project? project
    {
        get
        {
            return this;
        }
    }



    public override string name
    {
        get
        {
            return m_name;
        }
    }


    public override string path
    {
        get
        {
            return m_path;
        }
    }



    public string filename
    {
        get
        {
            return m_filename;
        }
        private set
        {
            string basename = null;
            string path = null;

            m_filename = value;

            if (m_filename != null)
            {
                basename = Path.get_basename(m_filename);
                path = Path.get_dirname(m_filename);
            }

            m_name = (basename == null) ? PROJECT_NAME : basename;
            m_path = (path == null) ? "Unknown" : path;

            changed(this);
        }
    }



    // needed for some reason
    private Project(ProjectNode parent)
    {
        base(parent);
    }



    /*
     *
     *
     */
    private Project.with_document(ProjectNode parent, string filename, Xml.Doc* document)

        requires(document != null)

    {
        base(parent);

        this.document = document;
        this.filename = filename;

        this.element = document->get_root_element();
    }



    /*
     *
     *
     *
     */
    public static Project create(ProjectNode parent, string filename)
    {
        Xml.Doc* document = new Xml.Doc("1.0");

        Xml.Node* root = new Xml.Node(null, PROJECT_NAME);

        document->set_root_element(root);

        return new Project.with_document(parent, filename, document);
    }



    /*
     *
     *
     *
     */
    public static Project load(ProjectNode parent, string filename) throws Error
    {
        Xml.Doc* document = Xml.Parser.read_file(filename);

        if (document == null)
        {
            throw new ProjectError.UNABLE_TO_LOAD(filename);
        }

        Xml.Node* root = document->get_root_element();

        if (root == null)
        {
            throw new ProjectError.MISSING_ROOT_ELEMENT(filename);
        }

        if (root->name != PROJECT_NAME)
        {
            throw new ProjectError.UNABLE_TO_LOAD(filename);
        }

        Project project = new Project.with_document(parent, filename, document);

        Xml.Node* child = root->children;

        while (child != null)
        {
            if (child->type != Xml.ElementType.ELEMENT_NODE)
            {
                child = child->next;
                continue;
            }

            if (child->name == "Design")
            {
                Design design = Design.load(project, child);
                project.add_design(design);
            }

            child = child->next;
        }

        return project;
    }



    /**
     * Create a new design and add it to this project.
     */
    public void create_design(string name, string subdir) throws Error

        requires(element != null)

    {
        string project_dir = Path.build_filename(path, subdir, null);

        if (FileUtils.test(project_dir, FileTest.EXISTS))
        {
            string message = "Directory '%s' already exists".printf(project_dir);

            throw new ProjectError.UNABLE_TO_CREATE(message);
        }

        if (DirUtils.create(project_dir, 0775) != 0)
        {
            string message = "Cannot create directory '%s'".printf(project_dir);

            throw new ProjectError.UNABLE_TO_CREATE(message);
        }

        Design design = Design.create(this, name, subdir);

        element->add_child(design.element);

        add_design(design);
    }



    /**
     * Save the project
     *
     *
     *
     */
    public void save() throws ProjectError
    {
        int bytes = document->save_format_file(filename, 1);

        if (bytes < 0)
        {
            throw new ProjectError.UNABLE_TO_SAVE(filename);
        }
    }



    private Gee.ArrayList<Design> m_designs;


    public string get_project_subdir(string basename)
    {
        return Path.build_filename(
            path,
            basename,
            null
            );
    }


    private void add_design(Design design)
    {
        if (m_designs == null)
        {
            m_designs = new Gee.ArrayList<Design>();
        }

        element->add_child(design.element);

        if (m_designs.size > 0)
        {
            m_designs.add(design);

            design.changed.connect(on_changed);
            design.inserted.connect(on_inserted);
            design.deleted.connect(on_deleted);
            design.toggled.connect(on_toggled);

            inserted(design);
            toggled(design);
        }
        else
        {
            m_designs.add(design);

            design.changed.connect(on_changed);
            design.inserted.connect(on_inserted);
            design.deleted.connect(on_deleted);
            design.toggled.connect(on_toggled);

            inserted(design);
            toggled(design);
            toggled(this);
        }
    }



    public Design? get_design(string name)
    {
        foreach (var design in m_designs)
        {
            if (design.name == name)
            {
                return design;
            }
        }

        return null;
    }


    /*
     *
     *
     *
     */
    public override ProjectNode? get_child(int index)
    {
        //stdout.printf("    Project.get_child()\n");
        //stdout.flush();

        ProjectNode? child = null;

        if (m_designs != null)
        {
            child = m_designs.get(index);
        }

        //stdout.printf("    Project.get_child() = %p\n", child);

        return child;
    }



    /*
     *
     *
     *
     */
    public override int get_child_count()
    {
        //stdout.printf("    Project.get_child_count()\n");
        //stdout.flush();

        int count = 0;

        if (m_designs != null)
        {
            count = m_designs.size;
        }

        //stdout.printf("    Project.get_child_count() = %d\n", count);

        return count;
    }



    /*
     *
     *
     *
     */
    public override bool get_child_index(ProjectNode node, out int index)
    {
        bool success = false;

        index = 0;

        if (m_designs != null)
        {
            success = m_designs.contains(node as Design);

            if (success)
            {
                index = m_designs.index_of(node as Design);
            }
        }

        return success;
     }



}
