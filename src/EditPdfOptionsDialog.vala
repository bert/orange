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
     * A dialog for editing the export options
     */
    public class EditPdfOptionsDialog : Gtk.Dialog, Gtk.Buildable
    {
        /**
         * The resource name for the UI design.
         */
        public const string RESOURCE_NAME = "/org/geda-project/orange/EditPdfOptionsDialog.xml";


        /**
         * The columns in the list store for the font family combo box
         */
        private enum FontColumn
        {
            NAME,
            COUNT
        }


        /**
         * The columns in the list store for the paper size combo box
         */
        private enum SizeColumn
        {
            ID,
            NAME,
            WIDTH,
            HEIGHT,
            COUNT
        }


        /**
         * A spin button for options.bottom_margin
         */
        private Gtk.SpinButton bottom_margin_spin;


        /**
         * A radio button for options.use_color
         */
        private Gtk.RadioButton color_radio;


        /**
         * A combo box for the options.font_family
         */
        private Gtk.ComboBox font_family_combo;


        /**
         * A spin button for the options.horizontal_alignment
         */
        private Gtk.SpinButton horizontal_alignment_spin;


        /**
         * A radio button for options.orientation
         */
        private Gtk.RadioButton landscape_radio;


        /**
         * A spin button for options.left_margin
         */
        private Gtk.SpinButton left_margin_spin;


        /**
         * A radio button for options.use_color
         */
        private Gtk.RadioButton no_color_radio;


        /**
         * Signal handler id for changes from the paper height spin button
         */
        private ulong paper_height_id;


        /**
         * A spin button for options.paper_height
         */
        private Gtk.SpinButton paper_height_spin;


        /**
         * Signal handler id for changes from the paper size combo box
         */
        private ulong paper_size_id;


        /**
         * A combo box for options.paper_name
         */
        private Gtk.ComboBox paper_size_combo;


        /**
         * Signal handler id for changes from the paper width spin button
         */
        private ulong paper_width_id;


        /**
         * A spin button for options.paper_width
         */
        private Gtk.SpinButton paper_width_spin;


        /**
         * A spin button for options.orientation
         */
        private Gtk.RadioButton portrait_radio;


        /**
         * A spin button for options.right_margin
         */
        private Gtk.SpinButton right_margin_spin;


        /**
         * A spin button for options.scale
         */
        private Gtk.SpinButton scale_spin;


        /**
         * A spin button for options.top_margin
         */
        private Gtk.SpinButton top_margin_spin;


        /**
         * A spin button for options.vertical_alignment
         */
        private Gtk.SpinButton vertical_alignment_spin;


        /**
         * Initialize the class.
         */
        class construct
        {
            set_template_from_resource(RESOURCE_NAME);
        }


        /**
         * Create the edit options dialog
         */
        public EditPdfOptionsDialog()
        {
            init_template();

            double maximum = 1000.0;

            /* page settings */

            Gtk.CellRendererText renderer = new Gtk.CellRendererText();
            paper_size_combo.pack_start(renderer, true);
            paper_size_combo.add_attribute(renderer, "text", SizeColumn.NAME);
            paper_size_combo.active = 0;

            paper_size_combo.model = create_paper_size_list_store();
            paper_size_combo.id_column = SizeColumn.ID;

            paper_width_spin.adjustment.lower = 0.0;
            paper_width_spin.adjustment.upper = maximum;
            paper_width_spin.adjustment.page_increment = 0.5;
            paper_width_spin.adjustment.step_increment = 0.5;
            paper_width_spin.climb_rate = 1.0;
            paper_width_spin.digits = 2;

            paper_height_spin.adjustment.lower = 0.0;
            paper_height_spin.adjustment.upper = maximum;
            paper_height_spin.adjustment.page_increment = 0.5;
            paper_height_spin.adjustment.step_increment = 0.5;
            paper_height_spin.climb_rate = 1.0;
            paper_height_spin.digits = 2;

            paper_size_id = paper_size_combo.changed.connect(on_paper_size_change);
            paper_width_id = paper_width_spin.changed.connect(on_paper_dimension_change);
            paper_height_id = paper_height_spin.changed.connect(on_paper_dimension_change);

            paper_size_combo.changed.connect(on_data_change);
            paper_width_spin.changed.connect(on_data_change);
            paper_height_spin.changed.connect(on_data_change);
            portrait_radio.toggled.connect(on_data_change);
            landscape_radio.toggled.connect(on_data_change);

            /* Margins */

            left_margin_spin.adjustment.lower = 0.0;
            left_margin_spin.adjustment.upper = maximum;
            left_margin_spin.adjustment.page_increment = 0.1;
            left_margin_spin.adjustment.step_increment = 0.1;
            left_margin_spin.climb_rate = 1.0;
            left_margin_spin.digits = 2;

            top_margin_spin.adjustment.lower = 0.0;
            top_margin_spin.adjustment.upper = maximum;
            top_margin_spin.adjustment.page_increment = 0.1;
            top_margin_spin.adjustment.step_increment = 0.1;
            top_margin_spin.climb_rate = 1.0;
            top_margin_spin.digits = 2;

            right_margin_spin.adjustment.lower = 0.0;
            right_margin_spin.adjustment.upper = maximum;
            right_margin_spin.adjustment.page_increment = 0.1;
            right_margin_spin.adjustment.step_increment = 0.1;
            right_margin_spin.climb_rate = 1.0;
            right_margin_spin.digits = 2;

            bottom_margin_spin.adjustment.lower = 0.0;
            bottom_margin_spin.adjustment.upper = maximum;
            bottom_margin_spin.adjustment.page_increment = 0.1;
            bottom_margin_spin.adjustment.step_increment = 0.1;
            bottom_margin_spin.climb_rate = 1.0;
            bottom_margin_spin.digits = 2;

            left_margin_spin.changed.connect(on_data_change);
            top_margin_spin.changed.connect(on_data_change);
            right_margin_spin.changed.connect(on_data_change);
            bottom_margin_spin.changed.connect(on_data_change);

            /* print settings */

            horizontal_alignment_spin.adjustment.lower = 0.0;
            horizontal_alignment_spin.adjustment.upper = 1.0;
            horizontal_alignment_spin.adjustment.page_increment = 0.1;
            horizontal_alignment_spin.adjustment.step_increment = 0.1;
            horizontal_alignment_spin.climb_rate = 1.0;
            horizontal_alignment_spin.digits = 2;

            vertical_alignment_spin.adjustment.lower = 0.0;
            vertical_alignment_spin.adjustment.upper = 1.0;
            vertical_alignment_spin.adjustment.page_increment = 0.1;
            vertical_alignment_spin.adjustment.step_increment = 0.1;
            vertical_alignment_spin.climb_rate = 1.0;
            vertical_alignment_spin.digits = 2;

            scale_spin.adjustment.lower = 0.0;
            scale_spin.adjustment.upper = 1000.0;
            scale_spin.adjustment.page_increment = 0.1;
            scale_spin.adjustment.step_increment = 0.1;
            scale_spin.climb_rate = 1.0;
            scale_spin.digits = 2;

            color_radio.toggled.connect(on_data_change);
            no_color_radio.toggled.connect(on_data_change);
            horizontal_alignment_spin.changed.connect(on_data_change);
            vertical_alignment_spin.changed.connect(on_data_change);
            scale_spin.changed.connect(on_data_change);

            renderer = new Gtk.CellRendererText();
            font_family_combo.pack_start(renderer, true);
            font_family_combo.add_attribute(renderer, "font", 0);
            font_family_combo.add_attribute(renderer, "text", 0);
            font_family_combo.active = 0;

            font_family_combo.model = create_font_family_list_store();
            font_family_combo.id_column = 0;

            ExportPdfOptions options = ExportPdfOptions();
            set_options(&options);
        }


        /**
         * Get the options from the widgets in the dialog
         *
         * It is anticipated that this function will throw an error in the
         * future if parsing the values in the widgets isn't sucsessful.
         */
        public ExportPdfOptions get_options()
        {
            var temp_options = ExportPdfOptions();

            temp_options.paper_name = paper_size_combo.active_id;
            temp_options.paper_width = paper_width_spin.value;
            temp_options.paper_height = paper_height_spin.value;
            temp_options.orientation = portrait_radio.active ? PaperOrientation.PORTRAIT : PaperOrientation.LANDSCAPE;

            temp_options.left_margin = left_margin_spin.value;
            temp_options.top_margin = top_margin_spin.value;
            temp_options.right_margin = right_margin_spin.value;
            temp_options.bottom_margin = bottom_margin_spin.value;

            temp_options.use_color = color_radio.active;
            temp_options.horizontal_alignment = horizontal_alignment_spin.value;
            temp_options.vertical_alignment = vertical_alignment_spin.value;
            temp_options.scale = scale_spin.value;

            temp_options.font_family = font_family_combo.active_id;

            return temp_options;
        }


        /**
         * Set the widgets in the dialog with the given options
         *
         * Passing in the struct by pointer eliminates the emitted code copying
         * the struct.
         */
        public void set_options(ExportPdfOptions *options)

            requires(options != null)

        {
            freeze_notify();

            SignalHandler.block(paper_size_combo, paper_size_id);
            SignalHandler.block(paper_width_spin, paper_width_id);
            SignalHandler.block(paper_height_spin, paper_height_id);

            if (!paper_size_combo.set_active_id(options->paper_name))
            {
                paper_size_combo.set_active_id(null);
            }

            paper_width_spin.value = options->paper_width;
            paper_height_spin.value = options->paper_height;

            SignalHandler.unblock(paper_size_combo, paper_size_id);
            SignalHandler.unblock(paper_width_spin, paper_width_id);
            SignalHandler.unblock(paper_height_spin, paper_height_id);

            if (options->orientation == PaperOrientation.PORTRAIT)
            {
                portrait_radio.active = true;
            }
            else
            {
                landscape_radio.active = true;
            }

            left_margin_spin.value = options->left_margin;
            top_margin_spin.value = options->top_margin;
            right_margin_spin.value = options->right_margin;
            bottom_margin_spin.value = options->bottom_margin;

            if (options->use_color)
            {
                color_radio.active = true;
            }
            else
            {
                no_color_radio.active = true;
            }

            horizontal_alignment_spin.value = options->horizontal_alignment;
            vertical_alignment_spin.value = options->vertical_alignment;
            scale_spin.value = options->scale;

            if (!font_family_combo.set_active_id(options->font_family))
            {
                font_family_combo.set_active_id(null);
            }

            thaw_notify();
        }


        /**
         *
         *
         */
        private void on_data_change()
        {
            try
            {
            }
            catch (Error error)
            {
            }
        }


        /**
         * Create a list store for the font family combo box
         */
        private Gtk.ListStore create_font_family_list_store()
        {
            var font_map = Pango.cairo_font_map_get_default();

            (unowned Pango.FontFamily)[] families;

            font_map.list_families(out families);

            var family_store = new Gtk.ListStore(
                FontColumn.COUNT,
                typeof(string)
                );

            foreach (Pango.FontFamily *item in families)
            {
                Gtk.TreeIter iter;

                family_store.append(out iter);

                family_store.set(
                    iter,
                    FontColumn.NAME, item->get_name()
                    );
            }

            return family_store;
        }


        /**
         * Create a list store for the paper size combo box
         */
        private Gtk.ListStore create_paper_size_list_store()
        {
            var sizes = Gtk.PaperSize.get_paper_sizes(false);

            var size_store = new Gtk.ListStore(
                SizeColumn.COUNT,
                typeof(string),
                typeof(string),
                typeof(double),
                typeof(double)
                );

            foreach (Gtk.PaperSize *item in sizes)
            {
                Gtk.TreeIter iter;

                size_store.append(out iter);

                size_store.set(
                    iter,
                    SizeColumn.ID,     item->get_name(),
                    SizeColumn.NAME,   item->get_display_name(),
                    SizeColumn.WIDTH,  item->get_width(Gtk.Unit.INCH),
                    SizeColumn.HEIGHT, item->get_height(Gtk.Unit.INCH)
                    );
            }

            return size_store;
        }


        /**
         * Event handler for changes to the paper width or height
         *
         * Changes to the dimensions of the paper assume the new value is a
         * custom paper size, so the name of the paper size is cleared.
         */
        private void on_paper_dimension_change()
        {
            SignalHandler.block(paper_size_combo, paper_size_id);

            paper_size_combo.set_active_iter(null);

            SignalHandler.unblock(paper_size_combo, paper_size_id);
        }


        /**
         * Event handler for changes to the paper size name
         *
         * Changing the paper size name updates the paper width and paper
         * height widgets.
         */
        private void on_paper_size_change()
        {
            Gtk.TreeIter iter;

            if (paper_size_combo.get_active_iter(out iter))
            {
                double paper_width;
                double paper_height;

                paper_size_combo.model.get(
                    iter,
                    SizeColumn.WIDTH, out paper_width,
                    SizeColumn.HEIGHT, out paper_height
                    );

                SignalHandler.block(paper_width_spin, paper_width_id);
                SignalHandler.block(paper_height_spin, paper_height_id);

                paper_width_spin.value = paper_width;
                paper_height_spin.value = paper_height;

                SignalHandler.unblock(paper_width_spin, paper_width_id);
                SignalHandler.unblock(paper_height_spin, paper_height_id);
            }
        }


        /**
         * Couldn't get the template bindings to work, so this function
         * obtains the objects from the Gtk.Builder.
         */
        private void parser_finished(Gtk.Builder builder)

            ensures(paper_size_combo != null)
            ensures(paper_width_spin != null)
            ensures(paper_height_spin != null)
            ensures(landscape_radio != null)
            ensures(portrait_radio != null)
            ensures(left_margin_spin != null)
            ensures(top_margin_spin != null)
            ensures(right_margin_spin != null)
            ensures(bottom_margin_spin != null)
            ensures(color_radio != null)
            ensures(no_color_radio != null)
            ensures(horizontal_alignment_spin != null)
            ensures(vertical_alignment_spin != null)
            ensures(scale_spin != null)
            ensures(font_family_combo != null)

        {
            paper_size_combo = builder.get_object("paper-size-combo") as Gtk.ComboBox;

            paper_width_spin = builder.get_object("paper-width-spin") as Gtk.SpinButton;
            paper_height_spin = builder.get_object("paper-height-spin") as Gtk.SpinButton;

            landscape_radio = builder.get_object("landscape-radio") as Gtk.RadioButton;
            portrait_radio = builder.get_object("portrait-radio") as Gtk.RadioButton;

            left_margin_spin = builder.get_object("left-margin-spin") as Gtk.SpinButton;
            top_margin_spin = builder.get_object("top-margin-spin") as Gtk.SpinButton;
            right_margin_spin = builder.get_object("right-margin-spin") as Gtk.SpinButton;
            bottom_margin_spin = builder.get_object("bottom-margin-spin") as Gtk.SpinButton;

            color_radio = builder.get_object("color-radio") as Gtk.RadioButton;
            no_color_radio = builder.get_object("no-color-radio") as Gtk.RadioButton;

            horizontal_alignment_spin = builder.get_object("horizontal-align-spin") as Gtk.SpinButton;
            vertical_alignment_spin = builder.get_object("vertical-align-spin") as Gtk.SpinButton;
            scale_spin = builder.get_object("scale-spin") as Gtk.SpinButton;

            font_family_combo = builder.get_object("font-family-combo") as Gtk.ComboBox;
        }
    }
}
