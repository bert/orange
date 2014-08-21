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
     * Options for exporting prints
     */
    public class ExportPdfOptions
    {
        /**
         * The backing store for the paper size
         */
        private Gtk.PaperSize back_paper_size;


        /**
         * The bottom margin
         */
        public double bottom_margin
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
        public Gtk.PaperSize paper_size
        {
            get
            {
                return back_paper_size;
            }
            set
            {
                back_paper_size = value.copy();
            }
        }


        /**
         * The page orientation
         */
        public Gtk.PageOrientation orientation
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
         *
         */
        public ExportPdfOptions(Gtk.Unit unit = Gtk.Unit.INCH)
        {
            paper_size = new Gtk.PaperSize(Gtk.PaperSize.get_default());

            bottom_margin = paper_size.get_default_bottom_margin(unit);
            left_margin = paper_size.get_default_left_margin(unit);
            right_margin = paper_size.get_default_right_margin(unit);
            top_margin = paper_size.get_default_top_margin(unit);

            orientation = Gtk.PageOrientation.LANDSCAPE;

            horizontal_alignment = 0.5;
            vertical_alignment = 0.5;
            scale = 1.0;

            use_color = true;
        }
    }
}
