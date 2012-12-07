


public class ProjectList : ProjectNode
{

    /** @brief Returns the name of the root node.
     *
     *  The root node will not appear in the tree.
     */
    public override string name
    {
        get
        {
            return "Root";
        }
    }


    // backing store for the project
    private Project? m_current;



    /** @brief The current project
     *
     *  A null indicates no project is currently open.
     *
     *  Because this is the root node, the toggled signal does not need to be
     *  emitted.
     */
    public Project? current
    {
        get
        {
            return m_current;
        }
        private set
        {
            if (m_current != null)
            {
                m_current.changed.disconnect(on_changed);
                m_current.deleted.disconnect(on_deleted);
                m_current.inserted.disconnect(on_inserted);
                m_current.toggled.disconnect(on_toggled);

                m_current = null;

                deleted(this, 0);
            }

            m_current = value;

            if (m_current != null)
            {
                m_current.changed.connect(on_changed);
                m_current.deleted.connect(on_deleted);
                m_current.inserted.connect(on_inserted);
                m_current.toggled.connect(on_toggled);

                inserted(m_current);
                toggled(m_current);
                toggled(this);
            }
        }
    }



    public bool has_changes
    {
        get;
        private set;
    }



    /** brief Create a new project list.
     *
     *  Create an empty project list.
     */
    public ProjectList()
    {
        base(null);
        current = null;
        has_changes = false;
    }



    /** brief Close the current project
     *
     *  This function closes the current project, if any. All unsaved changes will be lost.
     */
    public void close()
    {
        current = null;
        has_changes = false;
    }



    /** brief Create a new project
     *
     *  This function creates a new project. The current project will be
     *  discarded. All unsaved changes will be lost.
     */
    public void create(string filename) throws Error
    {
        if (!Path.is_absolute(filename))
        {
            string message = "Requires an absolute path '%s'".printf(filename);

            throw new ProjectError.UNABLE_TO_CREATE(message);
        }

        string project_dir = Path.get_dirname(filename);

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

        current = Project.create(this, filename);

        current.save();
    }



    /** brief Load a project from the filesystem
     *
     *  This function loads an existing project from the filesystem. The
     *  current project will be discarded. All unsaved changes will be lost.
     *
     *  @param filename The filename of the project to load
     */
    public void load(string filename) throws Error
    {
        current = Project.load(this, filename);
        has_changes = false;
    }

    // TODO: Do something

    /**
     *
     *
     *
     *
     */
    public void save() throws ProjectError

        requires(current != null)

    {
        current.save();
        has_changes = false;
    }



    public override ProjectNode? get_child(int index)
    {
        return (index == 0) ? current : null;
    }



    public override int get_child_count()
    {
        return (current != null) ? 1 : 0;
    }



    public override bool get_child_index(ProjectNode node, out int index)
    {
        index = 0;

        return (current != null) && (current == node as Project);
    }



     protected new void on_changed(ProjectNode node)
     {
         base.on_changed(node);
         has_changes = true;
     }

}
