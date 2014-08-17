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
     * A base class for batch operations.
     */
    public abstract class Batch
    {
        /**
         * The action that triggers this operation.
         */
        private Gtk.Action m_action;



        /**
         * The factory used to create dialog boxes.
         */
        protected DialogFactory m_factory;



        /**
         * Construct the base class
         */
        public Batch(DialogFactory factory, Gtk.Action action)
        {
            m_action = action;
            m_factory = factory;

            m_action.activate.connect(on_activate);
        }



        /**
         * Add a design to this batch operation.
         */
        public virtual void add_design(Design design)
        {
        }



        /**
         * Add a schematic to this batch operation.
         */
        public virtual void add_schematic(Schematic schematic)
        {
        }



        /**
         * Add a schematic to this batch operation.
         */
        public virtual void add_simulation(Simulation simulation)
        {
        }



        /**
         * Clear all nodes from this batch operation.
         */
        public abstract void clear();



        /**
         * Determines if the current batch is editable.
         */
        public abstract bool enabled();



        /**
         * Run the batch operation.
         */
        public abstract void run() throws Error;



        /**
         * Update the sensitivity of the action.
         */
        public void update()

            requires(m_action != null)

        {
            m_action.set_sensitive(enabled());
        }


        /**
         * Called when this operation is triggered.
         */
        private void on_activate(Gtk.Action sender)

            requires(m_factory != null)

        {
            try
            {
                run();
            }
            catch (Error error)
            {
                Gtk.Dialog dialog = m_factory.create_unknown_error_dialog(error);

                dialog.run();
                dialog.destroy();
            }
        }
    }
}
