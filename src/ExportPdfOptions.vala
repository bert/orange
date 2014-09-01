/*
 *  Copyright (C) 2013 Edward Hennessy
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
     * Options for exporting schematics in print format
     */
    public struct ExportPdfOptions
    {
        /**
         * The bottom margin
         */
        public double bottom_margin
        {
            get;
            set;
        }


        /**
         * The font family
         */
        public string? font_family
        {
            get;
            set;
        }


        /**
         * The horizontal alignment
         */
        public double horizontal_alignment
        {
            get;
            set;
        }


        /**
         * The left margin
         */
        public double left_margin
        {
            get;
            set;
        }


        /**
         * The paper size
         */
        public double paper_height
        {
            get;
            set;
        }


        /**
         * The name of the paper size
         */
        public string? paper_name
        {
            get;
            set;
        }


        /**
         * The paper size
         */
        public double paper_width
        {
            get;
            set;
        }


        /**
         * The page orientation
         */
        public PaperOrientation orientation
        {
            get;
            set;
        }


        /**
         * The right margin
         */
        public double right_margin
        {
            get;
            set;
        }


        /**
         * The top margin
         */
        public double top_margin
        {
            get;
            set;
        }


        /**
         * The scale
         */
        public double scale
        {
            get;
            set;
        }


        /**
         * Selects color output
         */
        public bool use_color
        {
            get;
            set;
        }


        /**
         * The vertical alignment
         */
        public double vertical_alignment
        {
            get;
            set;
        }


        /**
         * An identifier for use inside the document
         */
        private static const string BOTTOM_MARGIN_NAME = "BottomMargin";


        /**
         * An identifier for use inside the document
         */
        private static const string FONT_FAMILY_NAME = "FontFamily";


        /**
         * An identifier for use inside the document
         */
        private static const string HORIZONTAL_ALIGNMENT_NAME = "HorizontalAlignment";


        /**
         * An identifier for use inside the document
         */
        private static const string LEFT_MARGIN_NAME = "LeftMargin";


        /**
         * An identifier for use inside the document
         */
        private static const string ORIENTATION_NAME = "Orientation";


        /**
         * An identifier for use inside the document
         */
        private static const string PAPER_HEIGHT_NAME = "PaperHeight";


        /**
         * An identifier for use inside the document
         */
        private static const string PAPER_NAME_NAME = "PaperName";


        /**
         * An identifier for use inside the document
         */
        private static const string PAPER_WIDTH_NAME = "PaperWidth";


        /**
         * An identifier for use inside the document
         */
        private static const string RIGHT_MARGIN_NAME = "RightMargin";


        /**
         * An identifier for use inside the document
         */
        private static const string SCALE_NAME = "Scale";


        /**
         * An identifier for use inside the document
         */
        private static const string TOP_MARGIN_NAME = "TopMargin";


        /**
         * An identifier for use inside the document
         */
        private static const string USE_COLOR_NAME = "UseColor";


        /**
         * An identifier for use inside the document
         */
        private static const string VERTICAL_ALIGNMENT_NAME = "VerticalAlignment";


        /**
         * Initialize to reasonable default values
         */
        public ExportPdfOptions(Gtk.Unit unit = Gtk.Unit.INCH)
        {
            var paper_size = new Gtk.PaperSize(Gtk.PaperSize.get_default());

            paper_name = paper_size.get_name();

            paper_width = paper_size.get_width(unit);
            paper_height = paper_size.get_height(unit);

            bottom_margin = paper_size.get_default_bottom_margin(unit);
            left_margin = paper_size.get_default_left_margin(unit);
            right_margin = paper_size.get_default_right_margin(unit);
            top_margin = paper_size.get_default_top_margin(unit);

            orientation = PaperOrientation.LANDSCAPE;

            horizontal_alignment = 0.5;
            vertical_alignment = 0.5;
            scale = 1.0;

            use_color = true;
        }


        /**
         * Create a list of arguments for the gaf export command.
         */
        public Gee.Collection<string> get_arguments()
        {
            var arguments = new Gee.ArrayList<string>();

            /**
             * @todo layout argument not working in gaf export right now
             *
             * For now, the paper dimensions will be swapped.
             */
            if (orientation == PaperOrientation.PORTRAIT)
            {
                arguments.add("--size=%lfin:%lfin".printf(paper_width, paper_height));
            }
            else
            {
                arguments.add("--size=%lfin:%lfin".printf(paper_height, paper_width));
            }

            arguments.add(
                "--margins=%lfin:%lfin:%lfin:%lfin".printf(
                    top_margin,
                    left_margin,
                    bottom_margin,
                    right_margin
                    ));

            arguments.add(use_color ? "--color" : "--no-color");

            /**
             * @todo layout argument not working in gaf export right now
             *
             * arguments.add(
             *     "--layout=%s".printf(
             *         options.orientation.to_string()
             *         ));
             */

            arguments.add(
                "--align=%lf:%lf".printf(
                    horizontal_alignment,
                    vertical_alignment
                    ));

            arguments.add(
                "--scale=%lf".printf(
                    scale
                    ));

            if (font_family != null)
            {
                arguments.add("--font=%s".printf(font_family));
            }

            return arguments;
        }



        /**
         * Retrieve options from an XML node
         *
         * @param node The node containing the options
         */
        public void retrieve(Xml.Node *node) throws DocumentError

            requires(node != null)

        {
            paper_name = XmlMisc.retrieve_string(node, PAPER_NAME_NAME);

            paper_width = XmlMisc.retrieve_double(
                node,
                PAPER_WIDTH_NAME,
                paper_width
                );

            paper_height = XmlMisc.retrieve_double(
                node,
                PAPER_HEIGHT_NAME,
                paper_height
                );

            orientation = XmlMisc.retrieve_paper_orientation(
                node,
                ORIENTATION_NAME,
                orientation
                );

            left_margin = XmlMisc.retrieve_double(
                node,
                LEFT_MARGIN_NAME,
                left_margin
                );

            top_margin = XmlMisc.retrieve_double(
                node,
                TOP_MARGIN_NAME,
                top_margin
                );

            right_margin = XmlMisc.retrieve_double(
                node,
                RIGHT_MARGIN_NAME,
                right_margin
                );

            bottom_margin = XmlMisc.retrieve_double(
                node,
                BOTTOM_MARGIN_NAME,
                bottom_margin
                );

            use_color = XmlMisc.retrieve_boolean(
                node,
                USE_COLOR_NAME,
                use_color
                );

            horizontal_alignment = XmlMisc.retrieve_double(
                node,
                HORIZONTAL_ALIGNMENT_NAME,
                horizontal_alignment
                );

            vertical_alignment = XmlMisc.retrieve_double(
                node,
                VERTICAL_ALIGNMENT_NAME,
                vertical_alignment
                );

            scale = XmlMisc.retrieve_double(
                node,
                SCALE_NAME,
                scale
                );

            font_family = XmlMisc.retrieve_string(node, FONT_FAMILY_NAME);
        }


        /**
         * Store options in an XML node
         *
         * @param node The node to contain the options
         */
        public void store(Xml.Node *node) throws DocumentError

            requires(node != null)

        {
            XmlMisc.update_element(
                node,
                PAPER_NAME_NAME,
                paper_name
                );

            XmlMisc.update_element(
                node,
                PAPER_WIDTH_NAME,
                "%lf".printf(paper_width)
                );

            XmlMisc.update_element(
                node,
                PAPER_HEIGHT_NAME,
                "%lf".printf(paper_height)
                );

            XmlMisc.update_element(
                node,
                ORIENTATION_NAME,
                orientation.to_string()
                );

            XmlMisc.update_element(
                node,
                LEFT_MARGIN_NAME,
                "%lf".printf(left_margin)
                );

            XmlMisc.update_element(
                node,
                TOP_MARGIN_NAME,
                "%lf".printf(top_margin)
                );

            XmlMisc.update_element(
                node,
                RIGHT_MARGIN_NAME,
                "%lf".printf(right_margin)
                );

            XmlMisc.update_element(
                node,
                BOTTOM_MARGIN_NAME,
                "%lf".printf(bottom_margin)
                );

            XmlMisc.update_element(
                node,
                USE_COLOR_NAME,
                use_color.to_string()
                );

            XmlMisc.update_element(
                node,
                HORIZONTAL_ALIGNMENT_NAME,
                "%lf".printf(horizontal_alignment)
                );

            XmlMisc.update_element(
                node,
                VERTICAL_ALIGNMENT_NAME,
                "%lf".printf(vertical_alignment)
                );

            XmlMisc.update_element(
                node,
                SCALE_NAME,
                "%lf".printf(scale)
                );

            XmlMisc.update_element(
                node,
                FONT_FAMILY_NAME,
                font_family
                );
        }
    }
}
