package de.grammarcraft.epsilon.ui.config.properties;

import org.eclipse.core.resources.IProject;
import org.eclipse.jface.preference.PreferencePage;
import org.eclipse.jface.resource.JFaceResources;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.dialogs.PropertyPage;

import de.grammarcraft.epsilon.preferences.EpsilonPreferences;
import de.grammarcraft.epsilon.properties.Properties;
import de.grammarcraft.epsilon.ui.config.preferences.GeneratorPreferencePage;

public class GeneratorPropertyPage extends PropertyPage {

	private static final int TEXT_FIELD_WIDTH = 50;

	private Text textFieldGeneratorPath;

    private Button checkBoxSpaceInsteadNL;
    private Button checkBoxOptionGenerationOnly;

    private Button checkBoxOptionIgnoreTokenMarks;

    private Button checkBoxOptionNoReferenceCounting;

    private Button checkBoxOptionNoOptimization;

    private Button checkBoxOptionNoConstantTrees;

    private Text textFieldAdditionalOptions;

    private Text textFieldTargetDir;

	/**
	 * Constructor for SamplePropertyPage.
	 */
	public GeneratorPropertyPage() {
		super();
	}

	private void addFirstSection(Composite parent) {
		Composite composite = createDefaultComposite(parent);

        textFieldGeneratorPath = createTextField(
                GeneratorPreferencePage.LABEL_GENERATOR_PATH, 
                Properties.getGeneratorExecutablePath(getProject()), composite);
        textFieldTargetDir = createTextField(
                GeneratorPreferencePage.LABEL_GENERATOR_TARGET_DIR, 
                Properties.getGeneratorTargetDir(getProject()), composite);
        
//		//Label for path field
//		Label pathLabel = new Label(composite, SWT.NONE);
//		pathLabel.setText("Eclipse project path:");
//
//		// Path text field
//		Text pathValueText = new Text(composite, SWT.WRAP | SWT.READ_ONLY);
//		pathValueText.setText(((IResource) getElement()).getFullPath().toString());
	}

	private void addSecondSection(Composite parent) {		
		checkBoxOptionNoConstantTrees = addCheckBox(
                GeneratorPreferencePage.LABEL_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING, 
                Properties.getNoConstantTreesCollapsing(getProject()), parent);
		checkBoxOptionGenerationOnly = addCheckBox(
		        GeneratorPreferencePage.LABEL_GENERATOR_OPTION_GENERATION_ONLY, 
		        Properties.getGenerationOnly(getProject()), parent);
		checkBoxOptionNoOptimization = addCheckBox(
                GeneratorPreferencePage.LABEL_GENERATOR_OPTION_NO_OPTIMIZATION, 
                Properties.getNoOptimization(getProject()), parent);
		checkBoxOptionNoReferenceCounting = addCheckBox(
		        GeneratorPreferencePage.LABEL_GENERATOR_OPTION_NO_REFERENCE_COUNTING, 
		        Properties.getNoReferenceCounting(getProject()), parent);
		checkBoxOptionIgnoreTokenMarks = addCheckBox(
		        GeneratorPreferencePage.LABEL_GENERATOR_OPTION_IGNORE_TOKEN_MARKS, 
		        Properties.getIgnoreTokenMarks(getProject()), parent);
		checkBoxSpaceInsteadNL = addCheckBox(
		        GeneratorPreferencePage.LABEL_GENERATOR_OPTION_SPACE_INSTEAD_NL, 
		        Properties.getSpaceInsteadNL(getProject()), parent);
	}
	
	private void addThirdSection(Composite parent) {
	    Composite composite = createDefaultComposite(parent);

	    textFieldAdditionalOptions = createTextField(
	            GeneratorPreferencePage.LABEL_GENERATOR_ADDITIONAL_OPTIONS, 
	            Properties.getAdditionalGeneratorOptions(getProject()), composite);
	}


    private Text createTextField(String labelText, String intialValue, Composite composite) {
		Label label = new Label(composite, SWT.NONE);
		label.setText(labelText);

		GridData gd = new GridData();
		gd.widthHint = convertWidthInCharsToPixels(TEXT_FIELD_WIDTH);
		Text text = new Text(composite, SWT.SINGLE | SWT.BORDER);
		text.setLayoutData(gd);
		text.setText(intialValue);
		
		return text;
    }

    private static Button addCheckBox(String label, boolean initialValue, Composite parent) {
        Button checkBox = new Button(parent, SWT.CHECK);
		checkBox.setFont(JFaceResources.getDialogFont());
		checkBox.setText(label);
		checkBox.setSelection(initialValue);
		return checkBox;
    }

	private IProject getProject() {
	    return (IProject) getElement().getAdapter(IProject.class);
    }

    /**
	 * @see PreferencePage#createContents(Composite)
	 */
	protected Control createContents(Composite parent) {
		Composite composite = new Composite(parent, SWT.NONE);
		GridLayout layout = new GridLayout();
		composite.setLayout(layout);
		GridData data = new GridData(GridData.FILL);
		data.grabExcessHorizontalSpace = true;
		composite.setLayoutData(data);

		addFirstSection(composite);
//		addSeparator(composite);
		addSecondSection(composite);
		addThirdSection(composite);
		return composite;
	}

	private Composite createDefaultComposite(Composite parent) {
		Composite composite = new Composite(parent, SWT.NULL);
		GridLayout layout = new GridLayout();
		layout.numColumns = 2;
		composite.setLayout(layout);

		GridData data = new GridData();
		data.verticalAlignment = GridData.FILL;
		data.horizontalAlignment = GridData.FILL;
		composite.setLayoutData(data);

		return composite;
	}

	protected void performDefaults() {
		super.performDefaults();
		// Populate the owner text field with the default value
		textFieldGeneratorPath.setText(EpsilonPreferences.getGeneratorExecutablePath());
		textFieldTargetDir.setText(EpsilonPreferences.getGeneratorTargetDir());
		checkBoxOptionNoConstantTrees.setSelection(EpsilonPreferences.getNoConstantTreesCollapsing());
		checkBoxOptionGenerationOnly.setSelection(EpsilonPreferences.getGenerationOnly());
		checkBoxOptionNoOptimization.setSelection(EpsilonPreferences.getNoOptimization());
		checkBoxOptionNoReferenceCounting.setSelection(EpsilonPreferences.getNoReferenceCounting());
		checkBoxOptionIgnoreTokenMarks.setSelection(EpsilonPreferences.getIgnoreTokenMarks());
		checkBoxSpaceInsteadNL.setSelection(EpsilonPreferences.getSpaceInsteadNL());
		textFieldAdditionalOptions.setText(EpsilonPreferences.getAdditionalGeneratorOptions());
	}
	
	public boolean performOk() {
		// store the value in the owner text field
		try {
		    Properties.storeGeneratorExecutablePath(getProject(), textFieldGeneratorPath.getText());
		    Properties.storeGeneratorTargetDir(getProject(), textFieldTargetDir.getText());
		    Properties.storeNoConstantTreesCollapsing(getProject(), checkBoxOptionNoConstantTrees.getSelection());
		    Properties.storeGenerationOnly(getProject(), checkBoxOptionGenerationOnly.getSelection());
		    Properties.storeNoOptimization(getProject(), checkBoxOptionNoOptimization.getSelection());
		    Properties.storeNoReferenceCounting(getProject(), checkBoxOptionNoReferenceCounting.getSelection());
		    Properties.storeIgnoreTokenMarks(getProject(), checkBoxOptionIgnoreTokenMarks.getSelection());
		    Properties.storeSpaceInsteadNL(getProject(), checkBoxSpaceInsteadNL.getSelection());
		    Properties.storeAdditionalGeneratorOptions(getProject(), textFieldAdditionalOptions.getText());
		} catch (Exception e) {
		    // TODO logger.warn
			return false;
		}
		return true;
	}

}