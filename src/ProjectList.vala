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
 * Stores a list of the current projects
 *
 * This class stores current open projects, which is either zero or one. This
 * class is designed to persist across opening and closing projects.
 */
public class ProjectList : ProjectNode
{
    /**
     * Returns the name of the root node.
     *
     * The root node will not appear in the tree.
     */
    public override string name
    {
        get
        {
            return "Root";
        }
    }



    /**
     * The backing store for the current project
     *
     * To keep the signal handler connections in sync, only the property
     * getter and setter should access this backing store.
     */
    private Project? m_current;



    /**
     * The current project
     *
     * A null indicates no project is currently open.
     *
     * Because this is the root node, the toggled signal does not need to be
     * emitted.
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



    /**
     * Indicates changes have occured to the current project
     */
    public bool has_changes
    {
        get;
        private set;
    }



    /**
     * Create a new, empty project list.
     */
    public ProjectList()
    {
        base(null);
        current = null;
        has_changes = false;
    }



    /**
     * Close the current project
     *
     * This function closes the current project, if any. All unsaved changes will be lost.
     */
    public void close()
    {
        current = null;
        has_changes = false;
    }



    /**
     * Create a new project
     *
     * This function creates a new project. The current project will be
     * discarded. All unsaved changes will be lost.
     *
     * param filename The absolute path of the project file.
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



    /**
     * Load a project from the filesystem
     *
     * This function loads an existing project from the filesystem. The
     * current project will be discarded. All unsaved changes will be lost.
     *
     * param filename The absolute path of the project file to load
     */
    public void load(string filename) throws Error
    {
        if (!Path.is_absolute(filename))
        {
            string message = "Requires an absolute path '%s'".printf(filename);

            throw new ProjectError.UNABLE_TO_CREATE(message);
        }

        current = Project.load(this, filename);
        has_changes = false;
    }



    /**
     * Saves the current project
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
