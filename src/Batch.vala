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
/** @brief A base class for batch operations.
 */
public abstract class Batch
{
    /** @brief The action that triggers this operation.
     */
    private Gtk.Action m_action;



    /** @brief The factory used to create dialog boxes.
     *
     */
    protected DialogFactory m_factory;



    /** @brief
     */
    public Batch(DialogFactory factory, Gtk.Action action)
    {
        m_action = action;
        m_factory = factory;

        m_action.activate.connect(on_activate);
    }



    /** @brief Add a design to this batch operation.
     */
    public virtual void add_design(Design design)
    {
    }



    /** @brief Add a schematic to this batch operation.
     */
    public virtual void add_schematic(Schematic schematic)
    {
    }



    /** @brief Clear all nodes from this batch operation.
     */
    public abstract void clear();



    /** @brief Determines if the current batch is editable.
     */
    public abstract bool enabled();



    /** @brief Run the batch operation.
     */
    public abstract void run() throws Error;



    /** @brief Update the sensitivity of the action.
     */
    public void update()

        requires(m_action != null)

    {
        m_action.set_sensitive(enabled());
    }


    /** @brief Called when this operation is triggered.
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
