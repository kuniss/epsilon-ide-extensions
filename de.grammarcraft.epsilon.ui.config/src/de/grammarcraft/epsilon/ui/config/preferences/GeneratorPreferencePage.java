package de.grammarcraft.epsilon.ui.config.preferences;

import org.eclipse.core.runtime.preferences.InstanceScope;
import org.eclipse.jface.preference.BooleanFieldEditor;
import org.eclipse.jface.preference.FieldEditorPreferencePage;
import org.eclipse.jface.preference.FileFieldEditor;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.preference.StringFieldEditor;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;
import org.eclipse.ui.preferences.ScopedPreferenceStore;

import de.grammarcraft.epsilon.preferences.EpsilonPreferences;

/**
 * This class represents a preference page that
 * is contributed to the Preferences dialog. By 
 * subclassing <samp>FieldEditorPreferencePage</samp>, we
 * can use the field support built into JFace that allows
 * us to create a page that is small and knows how to 
 * save, restore and apply itself.
 * <p>
 * This page is used to modify preferences only. They
 * are stored in the preference store that belongs to
 * the main plug-in class. That way, preferences can
 * be accessed directly via the preference store.
 */

public class GeneratorPreferencePage
	extends FieldEditorPreferencePage
	implements IWorkbenchPreferencePage {

    public static final String LABEL_GENERATOR_PATH = "&Generator path:";
    public static final String LABEL_GENERATOR_TARGET_DIR = "Generator output folder:";
    public static final String LABEL_GENERATOR_ADDITIONAL_OPTIONS = "Additional Generator Options:";
    public static final String LABEL_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING = "Disable &collapsing constant trees (-c)";
    public static final String LABEL_GENERATOR_OPTION_GENERATION_ONLY = "&Generate only, do not compile, e.g if D compiler is missing (-g)";
    public static final String LABEL_GENERATOR_OPTION_NO_OPTIMIZATION = "Disable &optimizing of variable storage in generated compiler (-o)";
    public static final String LABEL_GENERATOR_OPTION_NO_REFERENCE_COUNTING = "Disable &reference counting in generated compiler (-r)";
    public static final String LABEL_GENERATOR_OPTION_IGNORE_TOKEN_MARKS = "&Parser ignores regular token marks at hyper-nonterminals (-p)";
    public static final String LABEL_GENERATOR_OPTION_SPACE_INSTEAD_NL = "Generated compiler uses &space instead of newline as separator (-s)";

    public GeneratorPreferencePage() {
		super(GRID);
		IPreferenceStore store = new ScopedPreferenceStore(InstanceScope.INSTANCE, "de.grammarcraft.epsilon");
	    setPreferenceStore(store);
		setDescription("Gamma/Epsilon Compiler Generator Preferences getting applied to all EAG files");
	}
	
	/**
	 * Creates the field editors. Field editors are abstractions of
	 * the common GUI blocks needed to manipulate various types
	 * of preferences. Each field editor knows how to save and
	 * restore itself.
	 */
	public void createFieldEditors() {
		addField(new FileFieldEditor(EpsilonPreferences.P_GENERATOR_EXE_PATH, 
				LABEL_GENERATOR_PATH, getFieldEditorParent()));
        addField(new StringFieldEditor(EpsilonPreferences.P_GENERATOR_TARGET_DIR, 
                LABEL_GENERATOR_TARGET_DIR, getFieldEditorParent()));

        // Gamma generator options
        //      -c               Disable collapsing constant trees
        //      -g               Generate only, do not compile
        //      -o               Disable optimizing of variable storage in compiled compiler
        //      -p               Parser ignores regular token marks at hyper-nonterminals
        //      -r               Disable reference counting in compiled compiler
        //      -s, --space      Compiled compiler uses space instead of newline as separator
        addField(
              new BooleanFieldEditor(
                      EpsilonPreferences.P_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING,
                      LABEL_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING,
                      getFieldEditorParent()));
        addField(
                new BooleanFieldEditor(
                        EpsilonPreferences.P_GENERATOR_OPTION_GENERATION_ONLY,
                        LABEL_GENERATOR_OPTION_GENERATION_ONLY,
                        getFieldEditorParent())); 
        addField(
                new BooleanFieldEditor(
                        EpsilonPreferences.P_GENERATOR_OPTION_NO_OPTIMIZATION,
                        LABEL_GENERATOR_OPTION_NO_OPTIMIZATION,
                        getFieldEditorParent()));
        addField(
                new BooleanFieldEditor(
                        EpsilonPreferences.P_GENERATOR_OPTION_NO_REFERENCE_COUNTING,
                        LABEL_GENERATOR_OPTION_NO_REFERENCE_COUNTING,
                        getFieldEditorParent()));
        addField(
                new BooleanFieldEditor(
                        EpsilonPreferences.P_GENERATOR_OPTION_IGNORE_TOKEN_MARKS,
                        LABEL_GENERATOR_OPTION_IGNORE_TOKEN_MARKS,
                        getFieldEditorParent()));
        addField(
                new BooleanFieldEditor(
                        EpsilonPreferences.P_GENERATOR_OPTION_SPACE_INSTEAD_NL,
                        LABEL_GENERATOR_OPTION_SPACE_INSTEAD_NL,
                        getFieldEditorParent()));   

        // if new gets added before LS gets adapted:
        addField(new StringFieldEditor(EpsilonPreferences.P_GENERATOR_ADDITIONAL_OPTIONS, 
                LABEL_GENERATOR_ADDITIONAL_OPTIONS, getFieldEditorParent()));

// Eclipse generated:
//		addField(
//			new BooleanFieldEditor(
//				PreferenceConstants.P_BOOLEAN,
//				"&An example of a boolean preference",
//				getFieldEditorParent()));
//
//		addField(new RadioGroupFieldEditor(
//				PreferenceConstants.P_CHOICE,
//			"An example of a multiple-choice preference",
//			1,
//			new String[][] { { "&Choice 1", "choice1" }, {
//				"C&hoice 2", "choice2" }
//		}, getFieldEditorParent()));
//		addField(
//			new StringFieldEditor(PreferenceConstants.P_STRING, "A &text preference:", getFieldEditorParent()));
	}

	/* (non-Javadoc)
	 * @see org.eclipse.ui.IWorkbenchPreferencePage#init(org.eclipse.ui.IWorkbench)
	 */
	public void init(IWorkbench workbench) {
	}
	
}