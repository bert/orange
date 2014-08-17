/*
 *  Copyright (C) 2012, 2013 Edward Hennessy
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
     * Represents a schematic in the project tree
     */
    public class Schematic : ProjectNode
    {
        /**
         * The element name of the XML node representing schematics
         */
        public const string ELEMENT_NAME = "sch";



        /**
         * The element name of the XML node representing schematics
         */
        private const string PROP_NAME_BASENAME = "file";



        /**
         * Backing store for the basename of the schematic file
         */
        private string m_basename;



        /**
         * Backing store for the full path of the schematic file
         */
        private string m_filename;



        /**
         * The XML element associated with this node.
         */
        public Xml.Node* element
        {
            get;
            private set;
        }


        public override unowned Gdk.Pixbuf icon
        {
            get
            {
                return pixbufs.fetch("schematic.svg");
            }
        }


        /**
         * The name of the node
         *
         * For schematics, the basename of the file is used as the name.
         */
        public override string name
        {
            get
            {
                return basename;
            }
        }



        /**
         * The basename for this schematic file.
         */
        public string basename
        {
            get
            {
                return m_basename = element->get_prop(PROP_NAME_BASENAME);
            }
        }



        /**
         * The dirname for this schematic
         */
        public override string path
        {
            get
            {
                return parent.path;
            }
        }



        /**
         * The filename of this schematic
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



        /**
         * Create a schematic project node
         *
         * param parent The parent node in the project tree
         * param element The XML node for the schematic
         */
        private Schematic(PixbufCache pixbufs, ProjectNode parent, Xml.Node* element)

            requires(element != null)

        {
            base(pixbufs, parent);
            this.element = element;
        }



        /**
         * Add this schematic to a batch operation.
         */
        public override void add_to_batch(Batch batch)
        {
            batch.add_schematic(this);
        }



        /**
         * Create an XML node for a schematic
         *
         * param filename the basename of the schematic file.
         */
        public static Xml.Node* create(string basename)
        {
            Xml.Node* element = new Xml.Node(null, ELEMENT_NAME);

            element->set_prop(PROP_NAME_BASENAME, basename);

            return element;
        }



        /**
         * Create a schematic project node from an existing XML node
         *
         * param parent The parent node in the project tree
         * param element The XML node for the schematic
         */
        public static Schematic load(PixbufCache pixbufs, ProjectNode parent, Xml.Node* element)

            requires(element != null)

        {
            return new Schematic(pixbufs, parent, element);
        }



        /*
         *
         *  The schematic has no child nodes, so this function returns 0.
         *
         */
        public override int get_child_count()
        {
            return 0;
        }



        /*
         *
         *  The schematic has no child nodes, so this function returns null.
         *
         */
        public override ProjectNode? get_child(int index)
        {
            return null;
        }



        /*
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
}
