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
namespace Orange
{
    /**
     * The base class for all nodes in the project tree.
     */
    public abstract class ProjectNode : GLib.Object
    {
        /**
         * Signals changes in a node.
         *
         * This signal is emitted when a node gets changed. This signal is
         * roughly equivalent to the property change notification, but for
         * properties visible in the view.
         *
         * param node The node that was changed.
         */
        public signal void changed(ProjectNode node);

        /**
         * Signals a node deleted from the project
         *
         * This signal is emitted when a node gets deleted. The signal should
         * be emitted after the node is removed from the model.
         *
         * param node The parent of the node that was deleted.
         * param index The index where the node was formerly located.
         */
        public signal void deleted(ProjectNode parent, int index);

        /**
         * Signals a node inserted into the project
         *
         * This signal is emitted when a node gets inserted. The signal should
         * be emitted after the node is inserted into the model.
         *
         * param node The node that was inserted.
         */
        public signal void inserted(ProjectNode node);

        /**
         * Signals a change in the "has children" property
         *
         * This signal is emitted when a node either gains the first child, or
         * loses the last child. This signal is essentially a property change
         * notification for a "bool has_child" property.
         *
         * param node The node that gained or lost a child.
         */
        public signal void toggled(ProjectNode node);



        /**
         * The icon to use for this project node.
         */
        public virtual Gdk.Pixbuf icon
        {
            get
            {
                return pixbufs.missing;
            }
        }



        /*
         *
         *
         *
         *
         */
        public abstract string name
        {
            get;
        }



        public virtual string path
        {
           get
           {
               return "Unknown";
           }
        }



        /**
         * The cache of images used by ProjectNode children
         */
        public PixbufCache pixbufs
        {
            get;
            private set;
        }



        /**
         * The design associated with this node.
         *
         * If no design is associated with this node, this property is null.
         */
        public virtual Design? design
        {
            get
            {
                if (parent == null)
                {
                    return null;
                }
                else
                {
                    return parent.design;
                }
            }
        }



        /**
         * The parent node
         *
         * All nodes must have a parent except for the root. The parent is
         * immutable after construction.
         */
        public ProjectNode? parent
        {
            get;
            private set;
        }



        /**
         * The project associated with this node.
         */
        public virtual Project? project
        {
            get
            {
                if (parent == null)
                {
                    return null;
                }
                else
                {
                    return parent.project;
                }
            }
        }

        /*
         *
         *
         *  param parent The parent of the node under construction.
         */
        public ProjectNode(PixbufCache pixbufs, ProjectNode? parent)
        {
            this.parent = parent;
            this.pixbufs = pixbufs;
        }



        /**
         * Add this node to a batch operation.
         */
        public virtual void add_to_batch(Batch batch)
        {
        }




        /*
         *
         *
         *
         *
         */
        public abstract ProjectNode? get_child(int index);


        /*
         *
         *
         *
         *
         */
        public abstract int get_child_count();



        /*
         *
         *
         *
         *
         */
        public abstract bool get_child_index(ProjectNode node, out int index);



        /*
         *
         *  @see changed
         *
         *  @param node The node that was changed.
         */
        protected void on_changed(ProjectNode node)
        {
            changed(node);
        }



        /*
         *
         *
         *
         *
         *  @see deleted
         *
         *  @param node The parent of the node that was deleted.
         *  @param index The index where the node was formerly located.
         */
        protected void on_deleted(ProjectNode parent, int index)
        {
            deleted(parent, index);
        }



        /*
         *
         *  @see inserted
         *
         *  @param node The node that was inserted.
         */
        protected void on_inserted(ProjectNode node)
        {
            inserted(node);
        }



        /*
         *
         *  @see toggled
         *
         *  @param node The node that gained or lost a child.
         */
        protected void on_toggled(ProjectNode node)
        {
            toggled(node);
        }
    }
}
