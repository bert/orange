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
public class ProjectTreeModel : GLib.Object, Gtk.TreeModel
{
    private int stamp;

    private ProjectList project_list;



    /*
     *
     *
     *
     */
    public ProjectTreeModel(ProjectList project_list)
    {
        stamp = (int)Random.next_int();

        this.project_list = project_list;

        this.project_list.changed.connect(this.on_changed);
        this.project_list.deleted.connect(this.on_deleted);
        this.project_list.inserted.connect(this.on_inserted);
        this.project_list.toggled.connect(this.on_toggled);
    }



    /*
     *
     *
     *
     *
     *  @param node The node that was changed.
     */
    private void on_changed(ProjectNode node)
    {
        ProjectNode child = node;
        ProjectNode? parent = child.parent;

        //stdout.printf("Changed\n");
        //stdout.printf("    1. child=%p, parent=%p\n", child, parent);
        //stdout.flush();

        if (parent != null)
        {
            int index;

            parent.get_child_index(child, out index);

            Gtk.TreeIter iter = Gtk.TreeIter()
            {
                stamp = stamp,
                user_data = parent,
                user_data2 = index.to_pointer()
            };

            Gtk.TreePath path = new Gtk.TreePath();

            while (parent != null)
            {
                parent.get_child_index(child, out index);

                path.prepend_index(index);

                child = parent;
                parent = child.parent;

                //stdout.printf("    n. child=%p, parent=%p\n", child, parent);
            }

            //string path_string = path.to_string();

            //stdout.printf("    path (%s)\n", path_string);

            row_changed(path, iter);
        }
    }



    /*
     *
     *
     *
     *
     *  @param node The node that was changed.
     */
    private void on_deleted(ProjectNode node, int index)
    {
        //stdout.printf("Deleted (%p, %d)\n", node, index);
        //stdout.flush();

        ProjectNode child = node;
        ProjectNode? parent = child.parent;

        Gtk.TreePath path = new Gtk.TreePath();

        path.prepend_index(index);

        while (parent != null)
        {
            parent.get_child_index(child, out index);

            path.prepend_index(index);

            child = parent;
            parent = child.parent;

            //stdout.printf("    n. child=%p, parent=%p\n", child, parent);
        }

        //string path_string = path.to_string();

        //stdout.printf("    path (%s)\n", path_string);

        row_deleted(path);
    }



    /*
     *
     *
     *
     *
     *  @param node The node that was inserted into the model.
     */
    private void on_inserted(ProjectNode node)
    {
        ProjectNode child = node;
        ProjectNode? parent = child.parent;

        //stdout.printf("Inserted\n");
        //stdout.printf("    1. child=%p, parent=%p\n", child, parent);
        //stdout.flush();

        if (parent != null)
        {
            int index;

            parent.get_child_index(child, out index);

            Gtk.TreeIter iter = Gtk.TreeIter()
            {
                stamp = stamp,
                user_data = parent,
                user_data2 = index.to_pointer()
            };

            Gtk.TreePath path = new Gtk.TreePath();

            while (parent != null)
            {
                parent.get_child_index(child, out index);

                path.prepend_index(index);

                child = parent;
                parent = child.parent;

                //stdout.printf("    n. child=%p, parent=%p\n", child, parent);
            }

            //string path_string = path.to_string();

            //stdout.printf("    path (%s)\n", path_string);

            row_inserted(path, iter);
        }
    }



    /*
     *
     *
     *
     *
     *
     */
    private void on_toggled(ProjectNode node)
    {
        ProjectNode child = node;
        ProjectNode? parent = child.parent;

        //stdout.printf("Toggled\n");
        //stdout.printf("    1. child=%p, parent=%p\n", child, parent);
        //stdout.flush();

        if (parent != null)
        {
            int index0;

            parent.get_child_index(child, out index0);

            Gtk.TreeIter iter = Gtk.TreeIter()
            {
                stamp = stamp,
                user_data = parent,
                user_data2 = index0.to_pointer()
            };


            Gtk.TreePath path = new Gtk.TreePath();

            while (parent != null)
            {
                int index;

                parent.get_child_index(child, out index);

                path.prepend_index(index);

                child = parent;
                parent = child.parent;

                //stdout.printf("    n. child=%p, parent=%p\n", child, parent);
            }

            //string path_string = path.to_string();

            //stdout.printf("    path (%s)\n", path_string);

            row_has_child_toggled(path, iter);
        }
    }



    /*

     *
     *
     */
    public bool iter_parent(out Gtk.TreeIter iter, Gtk.TreeIter child)

        requires(child.stamp == stamp)
        requires(child.user_data != null)

    {
        ProjectNode parent = (ProjectNode)child.user_data;

        ProjectNode? grand_parent = parent.parent;

        int index = 0;
        bool success = false;

        if (grand_parent != null)
        {
            success = grand_parent.get_child_index(parent, out index);
        }

        iter = Gtk.TreeIter()
        {
            stamp = stamp,
            user_data = grand_parent,
            user_data2 = index.to_pointer()
        };

        return success;
    }


    /*
     *
     *
     *
     */
    public bool iter_nth_child(out Gtk.TreeIter iter, Gtk.TreeIter? parent, int n)

        requires(n >= 0)

    {
        ProjectNode node = get_node(parent);

        iter = Gtk.TreeIter()
        {
            stamp = stamp,
            user_data = node,
            user_data2 = n.to_pointer()
        };

        return (n < node.get_child_count());
    }



    /*
     *
     *
     *
     */
    public bool iter_children(out Gtk.TreeIter iter, Gtk.TreeIter? parent)
    {
        return iter_nth_child(out iter, parent, 0);
    }



    /*
     *
     *
     *
     */
    public bool iter_has_child(Gtk.TreeIter iter)

        requires(iter.stamp == stamp)
        requires(iter.user_data != null)

    {
        return (get_node(iter).get_child_count() > 0);
    }



    /*
     *
     *
     *
     */
    public int iter_n_children(Gtk.TreeIter? iter)

        ensures(result >= 0)

    {
        return get_node(iter).get_child_count();
    }



    /*
     *
     *
     *
     */
    public bool iter_next(ref Gtk.TreeIter iter)
    {
        ProjectNode parent = (ProjectNode*)iter.user_data;

        int index = (int)(long)iter.user_data2;

        if ((index +1 )< parent.get_child_count())
        {
            iter.user_data2 = (index + 1).to_pointer();

        //    stdout.printf("    index=%d\n", index + 1);

            return true;
        }

          //              stdout.printf("    nope\n");

        return false;
    }



    /*
     *
     *
     *
     */
    public int get_n_columns()
    {
        return 4;
    }



    /*
     *
     *
     *
     */
    public Gtk.TreePath? get_path(Gtk.TreeIter iter)
    
        requires(iter.stamp == stamp)
        ensures(result != null)
    
    {
        Gtk.TreeIter node = iter;
        Gtk.TreePath path = new Gtk.TreePath();
    
        path.prepend_index((int)(long)node.user_data2);
        
        Gtk.TreeIter parent = Gtk.TreeIter();
        
        while (iter_parent(out parent, node))
        {
            node = parent;
            
            path.prepend_index((int)(long)node.user_data2);
        }
    
        return path;
    }



    /*
     *
     *
     *
     */
    public Type get_column_type(int column)
    {
        Type type;

        switch (column)
        {
            case 0:
                type = typeof(string);
                break;

            case 1:
                type = typeof(string);
                break;

            case 2:
                type = typeof(string);
                break;

            case 3:
                type = typeof(string);
                break;

            default:
                type = typeof(string);
                break;
        }

        return type;
    }



    /*
     *
     *
     *
     */
    public Gtk.TreeModelFlags get_flags()
    {
        //stdout.printf("get_flags\n");
        //stdout.flush();

        return 0;
    }



    /*
     *
     *
     *
     */
    public bool get_iter(out Gtk.TreeIter iter, Gtk.TreePath path)
    {
        int depth = path.get_depth();

        if (depth > 0)
        {
            ProjectNode node = project_list;
            int* child_index_list = path.get_indices();

            int path_index = 0;

            int child_index = *(child_index_list + path_index);

            if (child_index >= node.get_child_count())
            {
                iter = Gtk.TreeIter();
                return false;
            }

            while (++path_index < depth)
            {
                node = node.get_child(child_index);
                child_index = *(child_index_list + path_index);

                if (child_index >= node.get_child_count())
                {
                    iter = Gtk.TreeIter();
                    return false;
                }
            }

            iter = Gtk.TreeIter()
            {
               stamp = stamp,
               user_data = node,
               user_data2 = child_index.to_pointer()
            };

            return true;
        }

        iter = Gtk.TreeIter();

        return false;
    }



    /*
     *
     *
     *
     */
    public void get_value(Gtk.TreeIter iter, int column, out Value value)

        requires(iter.stamp == stamp)
        requires(column >= 0)

    {
        ProjectNode node = get_node(iter);

        switch (column)
        {
            case 0:
                value = node.icon;
                break;

            case 1:
                value = node.name; //node.design.path;
                break;

            case 2:
                value = "2";
                break;

            case 3:
                value = "3";
                break;

            default:
                value = "None";
                break;
        }
    }



    public List<ProjectNode> convert(List<Gtk.TreePath> paths)
    {
        Gtk.TreeIter iter;
        List<ProjectNode> nodes = new List<ProjectNode>();
        
        foreach (var path in paths)
        {
            if (get_iter(out iter, path))
            {
                nodes.append(get_node(iter));
            }
        }
        
        return nodes;
    }


    /*
     *
     *  param
     *
     */
    private ProjectNode get_node(Gtk.TreeIter? iter)

        ensures(result != null)

    {
        ProjectNode node = project_list;

        if (iter != null)
        {
            ProjectNode parent = iter.user_data as ProjectNode;

            int index = (int)(long)iter.user_data2;

            node = parent.get_child(index);
        }

        return node;
    }
}
