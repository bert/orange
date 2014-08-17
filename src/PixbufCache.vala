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

using GLib;

namespace Orange
{
    /**
     * A cache for storing similar size pixbufs loaded from files.
     */
    public class PixbufCache : GLib.Object
    {
        /**
         * The directory containing the pixbufs.
         */
        [CCode(cname = "IMAGE_DIR")]
        private extern static const string IMAGE_DIR;



        /**
         * A cache to store loaded pixbufs
         */
        private Gee.HashMap<string,Gdk.Pixbuf> cache
        {
            get;
            private set;
        }



        /**
         * A pixbuf representing a missing icon
         */
        public Gdk.Pixbuf missing
        {
            get;
            private set;
        }



        /**
         * The height to scale loaded pixbufs to
         */
        public int height
        {
            get;
            private set;
        }



        /**
         * The toplevel widget for this application
         */
        public Gtk.Widget top
        {
            get;
            private set;
        }



        /**
         * The width to scale loaded pixbufs to
         */
        public int width
        {
            get;
            private set;
        }



        /**
         * Create a new cache for storing similar size pixbufs
         *
         * param width The width to scale loaded pixbufs to
         * param height The height to scale loaded pixbufs to
         */
        public PixbufCache(Gtk.Widget top, Gtk.IconSize size)
        {
            cache = new Gee.HashMap<string,Gdk.Pixbuf>();

            this.top = top;

            missing = top.render_icon(Gtk.Stock.MISSING_IMAGE, size, null);

            width = missing.width;
            height = missing.height;
        }



        /**
         * Load a pixbuf from a file
         *
         * Either loads the pixbuf from a file, or returns an existing pixbuf
         * if already loaded.
         *
         * param basename The basename of the pixbuf file.
         */
        public unowned Gdk.Pixbuf fetch(string basename)

            requires(cache != null)

        {
            Gdk.Pixbuf* pixbuf;

            if (cache.has_key(basename))
            {
                pixbuf = cache[basename];
            }
            else
            {
                try
                {
                    string filename = Path.build_filename(IMAGE_DIR, basename, null);

                    pixbuf = new Gdk.Pixbuf.from_file_at_size(filename, width, height);

                    cache.set(basename, pixbuf);
                }
                catch
                {
                    pixbuf = missing;
                }
            }

            return pixbuf;
        }
    }
}
