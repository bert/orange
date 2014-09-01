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
    namespace XmlMisc
    {
        /**
         * Find a single element
         *
         * If more than one element exists with the same name, this function
         * throws an error.
         *
         * @param parent The node containg the elements to search
         * @param name The name of the element
         */
        public Xml.Node* find_element(Xml.Node *parent, string name) throws DocumentError
        {
            Xml.Node *node = null;

            for (Xml.Node *iter = parent->children; iter != null; iter = iter->next)
            {
                if (iter->type != Xml.ElementType.ELEMENT_NODE)
                {
                    continue;
                }

                if (iter->name != name)
                {
                    continue;
                }

                if (node == null)
                {
                    node = iter;
                }
                else
                {
                    throw new DocumentError.DUPLICATE_NODES(
                        "%s:%ld: Duplicate '%s' elements".printf(
                            Filename.display_basename(iter->doc->url),
                            iter->get_line_no(),
                            name
                            )
                        );
                }
            }

            return node;
        }


        /**
         * Obtain an element: find and create if necessary
         *
         * If an element with the name exists, this function returns that
         * element.
         *
         * If no element with the given name exists, this function creates a
         * new element, adds it to the children of the parent, and returns the
         * new element.
         *
         * @param parent
         * @param name The name of the element
         * @return The found or created node
         */
        Xml.Node* obtain_element(Xml.Node *parent, string name) throws DocumentError
        {
            Xml.Node *node = find_element(parent, name);

            if (node == null)
            {
                node = parent->new_child(null, name);
            }

            return node;
        }


        /**
         * Remove nodes from the document
         *
         * @param parent The parent of the nodes to remove
         * @param name The name of the nodes to remove
         */
        public void remove_all_elements(Xml.Node *parent, string name)
        {
            var nodes = new Gee.ArrayList<Xml.Node*>();

            for (Xml.Node *iter = parent->children; iter != null; iter = iter->next)
            {
                if (iter->type != Xml.ElementType.ELEMENT_NODE)
                {
                    continue;
                }

                if (iter->name != name)
                {
                    continue;
                }

                nodes.add(iter);
            }

            foreach (var node in nodes)
            {
                node->unlink();
                delete node;
            }
        }


        /**
         * Get the boolean contents of an element node
         *
         * @param [in] parent The parent of the element node
         * @param [in] name The name of the element node
         * @param [in] boolean The default return value if no node with the
         * given name exists.
         * @return The contents of the element node, or the boolean
         * parameter if no node with the given name exists.
         */
        public bool retrieve_boolean(Xml.Node *parent, string name, bool boolean) throws DocumentError
        {
            Xml.Node *node = find_element(parent, name);

            if (node != null)
            {
                string str = node->get_content();

                if (!bool.try_parse(str, out boolean))
                {
                    throw new DocumentError.EXPECTING_BOOLEAN(
                        "%s:%ld: Expecting boolean value in '%s' element".printf(
                            Filename.display_basename(node->doc->url),
                            node->get_line_no(),
                            name
                            )
                        );
                }
            }

            return boolean;
        }


        /**
         * Get the double contents of an element node
         *
         * @param [in] parent The parent of the element node
         * @param [in] name The name of the element node
         * @param [in] number The default return value if no node with the
         * given name exists.
         * @return The contents of the element node, or the number
         * parameter if no node with the given name exists.
         */
        public double retrieve_double(Xml.Node *parent, string name, double number) throws DocumentError
        {
            Xml.Node *node = find_element(parent, name);

            if (node != null)
            {
                string str = node->get_content();

                if (!double.try_parse(str, out number))
                {
                    throw new DocumentError.EXPECTING_DOUBLE(
                        "%s:%ld: Expecting double value in '%s' element".printf(
                            Filename.display_basename(node->doc->url),
                            node->get_line_no(),
                            name
                            )
                        );
                }
            }

            return number;
        }


        /**
         * Get the paper orientation contents of an element node
         *
         * @param [in] parent The parent of the element node
         * @param [in] name The name of the element node
         * @param [in] orientation The default return value if no node with the
         * given name exists.
         * @return The contents of the element node, or the orientation
         * parameter if no node with the given name exists.
         */
        public PaperOrientation retrieve_paper_orientation(Xml.Node *parent, string name, PaperOrientation orientation) throws DocumentError
        {
            Xml.Node *node = find_element(parent, name);

            if (node != null)
            {
                string str = node->get_content();

                if (!PaperOrientation.try_parse(str, out orientation))
                {
                    throw new DocumentError.EXPECTING_PAPER_ORIENTATION(
                        "%s:%ld: Expecting paper orientation value in '%s' element".printf(
                            Filename.display_basename(node->doc->url),
                            node->get_line_no(),
                            name
                            )
                        );
                }
            }

            return orientation;
        }


        /**
         * Get the string contents of an element node
         *
         * If no element node with the given name exists, this function will
         * return null.
         *
         * @param [in] parent The parent of the element node
         * @param [in] name The name of the element node
         * @return The contents of the element node, or null if no node with
         * the given name exists.
         */
        public string? retrieve_string(Xml.Node *parent, string name) throws DocumentError
        {
            Xml.Node *node = find_element(parent, name);
            string? str = null;

            if (node != null)
            {
                str = node->get_content();
            }

            return str;
        }


        /**
         * Update an element node with new contents
         *
         * If no element node with the given name exists, this function will
         * create a new element node.
         *
         * If the value is null, this function will remove all element nodes,
         * with the given name, from the document.
         *
         * @param [in] parent The parent of the element node
         * @param [in] name The name of the element node
         * @param [in] value The new contents for the element node
         */
        public void update_element(Xml.Node *parent, string name, string? value) throws DocumentError
        {
            if (value != null)
            {
                Xml.Node *node = obtain_element(parent, name);

                node->set_content(value);
            }
            else
            {
                remove_all_elements(parent, name);
            }
        }
    }
}
