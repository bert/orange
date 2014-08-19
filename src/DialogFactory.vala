using Gtk;

namespace Orange
{
    public class DialogFactory
    {
        public enum ConfirmSaveResponseType
        {
            DISCARD = ResponseType.REJECT,
            CANCEL = ResponseType.CANCEL,
            SAVE = ResponseType.OK
        }



        /**
         * The package data directory from the GNU autotools.
         *
         * This string contains the installation directory of the data
         * files.
         */
        [CCode(cname = "PKGDATADIR")]
        public static extern const string PKGDATADIR;



        /**
         * The subdirectory for the XML GtkBuilder files.
         *
         * This subdir is relative to the PKGDATADIR.
         */
        public static const string XML_SUBDIR = "xml";



        /**
         * The parent window
         *
         * Use as the parent for creating dialog boxes.
         */
        public Gtk.Window Parent
        {
            get;
            private set;
        }



        /**
         * Create a new DialogFactory
         *
         * param parent The parent for creating dialog boxes.
         */
        public DialogFactory(Gtk.Window parent)
        {
            Parent = parent;

            /* Need to register types with the glib type system for dynamic
             * construction with gtkbuilder. Need to figure out a better way
             * to ensure the calls to typeof() are not optimized out.
             */

            stdout.printf("Registering %s\n", typeof(AboutDialog).name());
            stdout.printf("Registering %s\n", typeof(AddSimulationDialog).name());
            stdout.printf("Registering %s\n", typeof(ArchiveSchematicsDialog).name());
            stdout.printf("Registering %s\n", typeof(ExportBOMDialog).name());
            stdout.printf("Registering %s\n", typeof(ExportNetlistDialog).name());
            stdout.printf("Registering %s\n", typeof(NewDesignDialog).name());
            stdout.printf("Registering %s\n", typeof(NewProjectDialog).name());
            stdout.printf("Registering %s\n", typeof(RenumberRefdesDialog).name());
            stdout.printf("Registering %s\n", typeof(ResetRefdesDialog).name());
            stdout.printf("Registering %s\n", typeof(BackannotateRefdesDialog).name());
        }



        // todo: Add a better enumeration for the responses

        public MessageDialog create_confirm_save_dialog(string? filename)
        {
            MessageDialog dialog;

            if (filename == null)
            {
                dialog = new MessageDialog.with_markup(
                    Parent,
                    DialogFlags.DESTROY_WITH_PARENT,
                    MessageType.QUESTION,
                    ButtonsType.NONE,
                    "<big>Save changes to <b>Untitled</b>?</big>\n\nThis file has not been saved. Unsaved changes will be lost."
                    );
            }
            else
            {
                dialog = new MessageDialog.with_markup(
                    Parent,
                    DialogFlags.DESTROY_WITH_PARENT,
                    MessageType.QUESTION,
                    ButtonsType.NONE,
                    "<big>Save changes to <b>%s</b>?</big>\n\nThe following file has been modified since last saved. Unsaved changes will be lost.\n\n<i>%s </i>",
                    Path.get_basename(filename),
                    filename
                    );
            }

            dialog.add_buttons(
                Stock.DISCARD, ConfirmSaveResponseType.DISCARD,
                Stock.CANCEL,  ConfirmSaveResponseType.CANCEL,
                Stock.SAVE,    ConfirmSaveResponseType.SAVE,
                null
                );

            dialog.set_default_response(ResponseType.OK);

            return dialog;
        }



        /*
         *
         *
         *
         */
        public MessageDialog create_file_not_found_dialog(string filename)
        {
            MessageDialog dialog = new MessageDialog.with_markup(
                Parent,
                DialogFlags.DESTROY_WITH_PARENT,
                MessageType.ERROR,
                ButtonsType.OK,
                "<big>File not found: <b>%s</b>.</big>\n\nThe following file was not found.\n\n<i>%s </i>",
                Path.get_basename(filename),
                filename
                );

            return dialog;
        }


        public MessageDialog create_unable_to_open_dialog(string? filename)
        {
            MessageDialog dialog = new MessageDialog.with_markup(
                Parent,
                DialogFlags.DESTROY_WITH_PARENT,
                MessageType.ERROR,
                ButtonsType.OK,
                "<big>Unable to open: <b>%s</b>.</big>\n\nThe following file could not be opened.\n\n<i>%s </i>",
                Path.get_basename(filename),
                filename
                );

            return dialog;
        }



        public MessageDialog create_unknown_error_dialog(Error error)
        {
            MessageDialog dialog = new MessageDialog.with_markup(
                Parent,
                DialogFlags.DESTROY_WITH_PARENT,
                MessageType.ERROR,
                ButtonsType.OK,
                "<big>An error occured.</big>\n\nThe program threw the following error.\n\n<i>%s </i>",
                error.message
                );

            return dialog;
        }
    }
}
