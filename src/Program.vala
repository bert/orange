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
     * @brief A program for managing projects.
     */
    public class Program : Gtk.Application
    {
        /**
         * The the id of the menubar in the resource file
         */
        public const string MENUBAR_ID = "menu";


        /**
         * The resource name for the UI design.
         */
        public const string RESOURCE_NAME = "/org/geda-project/orange/Program.xml";


        /**
         * @brief Construct the program
         */
        public Program()
        {
            Object(
                application_id: "org.geda-project.orange",
                flags: ApplicationFlags.HANDLES_OPEN
                );
        }


        /**
         * @brief The program entry point.
         */
        public static void main(string[] args)
        {
            try
            {
                new Program().run(args);
            }
            catch (Error error)
            {
                stderr.printf("%s\n", error.message);
            }
        }


        /**
         * @brief Create a new main window
         */
        protected override void activate()
        {
            try
            {
                var window = new MainWindow();

                return_if_fail(window != null);

                this.add_window(window);

                window.show_all();
            }
            catch (Error error)
            {
                stderr.printf("%s\n", error.message);
            }
        }


        /**
         * @brief Open files along with a new window for each file.
         *
         * @param files The files to open
         * @param hint unused
         */
        protected override void open(File[] files, string hint)
        {
            foreach (var file in files)
            {
                try
                {
                    var window = new MainWindow(file);

                    return_if_fail(window != null);

                    this.add_window(window);

                    window.show_all();
                }
                catch (Error error)
                {
                    stderr.printf("%s\n", error.message);
                }
            }
        }


        /**
         * @brief Called after the applicaton is registered
         */
        protected override void startup()
        {
            base.startup();

            try
            {
                var builder = new Gtk.Builder.from_resource(RESOURCE_NAME);

                menubar = builder.get_object(MENUBAR_ID) as MenuModel;
            }
            catch (Error error)
            {
                stderr.printf("%s\n", error.message);
            }
        }
    }
}
