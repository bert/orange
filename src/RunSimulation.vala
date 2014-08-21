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
     * A batch operation to run design simulations in the project tree.
     */
    public class RunSimulation : Batch
    {
        /**
         * A set of all the simulations in the batch operation.
         *
         * The operation uses a set to eliminate duplicates.
         */
        private Gee.HashSet<Simulation> m_simulations;



        /**
         * Create a new, empty batch operation.
         */
        public RunSimulation(DialogFactory factory, SimpleAction action)
        {
            base(factory, action);

            m_simulations = new Gee.HashSet<Simulation>();

            update();
        }



        /**
         * Add a simulation to the batch operation.
         */
        public override void add_simulation(Simulation simulation)

            requires(m_simulations != null)

        {
            m_simulations.add(simulation);
        }



        /**
         * Clear all nodes from the batch operation.
         */
        public override void clear()

            requires(m_simulations != null)

        {
            m_simulations.clear();
        }



        /**
         * Determines if the current batch can be simulated.
         */
        public override bool enabled()

            requires(m_simulations != null)

        {
            return (m_simulations.size > 0);
        }



        /**
         * Run the batch operation.
         */
        public override void run() throws Error

            requires(m_simulations != null)

        {
            foreach (var simulation in m_simulations)
            {
                simulation.run();
            }
        }
    }
}
