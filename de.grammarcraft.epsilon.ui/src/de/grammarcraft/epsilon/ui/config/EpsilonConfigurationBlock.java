/**
 * Copyright 2023 kuniss@grammarcraft.de
 */
package de.grammarcraft.epsilon.ui.config;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.jface.dialogs.IDialogSettings;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.forms.widgets.ExpandableComposite;
import org.eclipse.xtext.Constants;
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess;
import org.eclipse.xtext.ui.editor.preferences.PreferenceConstants;
import org.eclipse.xtext.ui.preferences.OptionsConfigurationBlock;
import org.eclipse.xtext.ui.preferences.ScrolledPageContent;

import com.google.inject.Inject;
import com.google.inject.name.Named;

import de.grammarcraft.epsilon.preferences.IEpsilonPreferences;
import de.grammarcraft.epsilon.ui.internal.EpsilonActivator;

/**
 * This implementation and idea is derived from 
 * org.eclipse.xtext.builder_2.25.0.v20210301-0928.jar:org.eclipse.xtext.builder.preferences.BuilderConfigurationBlock
 * 
 * @author kuniss@grammarcraft.de
 */
public class EpsilonConfigurationBlock extends OptionsConfigurationBlock {
    
    protected static final String[] BOOLEAN_VALUES = new String[] { IPreferenceStore.TRUE, IPreferenceStore.FALSE };
    
    protected static final int INDENT_AMOUNT = 32;
    
    public static final String SETTINGS_SECTION_NAME = "EpsilonConfigurationBlock"; //$NON-NLS-1$

    private String languageName;

    @Inject
    public void setLanguageName(@Named(Constants.LANGUAGE_NAME) String languageName) {
        this.languageName = languageName;
    }

    @Inject
    private IPreferenceStoreAccess preferenceStoreAccess;
    
    @Override
    public void setProject(IProject project) {
        super.setProject(project);
        setPreferenceStore(preferenceStoreAccess.getWritablePreferenceStore(project));
    }
    
    @Override
    protected Control doCreateContents(Composite parent) {
        setShell(parent.getShell());
        Composite mainComp = new Composite(parent, SWT.NONE);
        mainComp.setFont(parent.getFont());
        GridLayout layout = new GridLayout();
        layout.marginHeight = 0;
        layout.marginWidth = 0;
        mainComp.setLayout(layout);
        Composite othersComposite = createBuildPathTabContent(mainComp);
        GridData gridData = new GridData(GridData.FILL, GridData.FILL, true, true);
        othersComposite.setLayoutData(gridData);
        validateSettings(null, null, null);
        return mainComp;
    }


    private Composite createBuildPathTabContent(Composite parent) {
        int columns = 3;
        final ScrolledPageContent pageContent = new ScrolledPageContent(parent);
        GridLayout layout = new GridLayout();
        layout.numColumns = columns;
        layout.marginHeight = 0;
        layout.marginWidth = 0;

        Composite composite = pageContent.getBody();
        composite.setLayout(layout);
        String label = "General";
        ExpandableComposite excomposite = createStyleSection(composite, label, columns);

        Composite othersComposite = new Composite(excomposite, SWT.NONE);
        excomposite.setClient(othersComposite);
        othersComposite.setLayout(new GridLayout(columns, false));

        createGeneralSectionItems(othersComposite);

        registerKey(getIsProjectSpecificPropertyKey(getPropertyPrefix()));
        IDialogSettings section = EpsilonActivator.getInstance().getDialogSettings().getSection(SETTINGS_SECTION_NAME);
        restoreSectionExpansionStates(section);
        return pageContent;
    }
    
    public static final String LABEL_GENERATOR_PATH = "&Generator path:";
    public static final String LABEL_GENERATOR_TARGET_DIR = "Generator output folder:";
    public static final String LABEL_GENERATOR_ADDITIONAL_OPTIONS = "Additional Generator Options:";
    public static final String LABEL_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING = "Disable &collapsing constant trees (-c)";
    public static final String LABEL_GENERATOR_OPTION_GENERATION_ONLY = "&Generate only, do not compile, e.g if D compiler is missing (-g)";
    public static final String LABEL_GENERATOR_OPTION_NO_OPTIMIZATION = "Disable &optimizing of variable storage in generated compiler (-o)";
    public static final String LABEL_GENERATOR_OPTION_NO_REFERENCE_COUNTING = "Disable &reference counting in generated compiler (-r)";
    public static final String LABEL_GENERATOR_OPTION_IGNORE_TOKEN_MARKS = "&Parser ignores regular token marks at hyper-nonterminals (-p)";
    public static final String LABEL_GENERATOR_OPTION_SPACE_INSTEAD_NL = "Generated compiler uses &space instead of newline as separator (-s)";

    protected void createGeneralSectionItems(Composite composite) {
        addTextField(composite, LABEL_GENERATOR_PATH,
                getKey(IEpsilonPreferences.GENERATOR_EXE_PATH), 0, 0);
        addTextField(composite, LABEL_GENERATOR_TARGET_DIR,
                getKey(IEpsilonPreferences.GENERATOR_TARGET_DIR), 0, 0);
        addCheckBox(composite, LABEL_GENERATOR_OPTION_GENERATION_ONLY,
                getKey(IEpsilonPreferences.OPTION_GENERATION_ONLY), BOOLEAN_VALUES, 0);
        addCheckBox(composite, LABEL_GENERATOR_OPTION_IGNORE_TOKEN_MARKS,
                getKey(IEpsilonPreferences.OPTION_IGNORE_TOKEN_MARKS), BOOLEAN_VALUES, 0);
        addCheckBox(composite, LABEL_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING,
                getKey(IEpsilonPreferences.OPTION_NO_CONSTANT_TREES_COLLAPSING), BOOLEAN_VALUES, 0);
        addCheckBox(composite, LABEL_GENERATOR_OPTION_NO_OPTIMIZATION,
                getKey(IEpsilonPreferences.OPTION_NO_OPTIMIZATION), BOOLEAN_VALUES, 0);
        addCheckBox(composite, LABEL_GENERATOR_OPTION_NO_REFERENCE_COUNTING,
                getKey(IEpsilonPreferences.OPTION_NO_REFERENCE_COUNTING), BOOLEAN_VALUES, 0);
        addCheckBox(composite, LABEL_GENERATOR_OPTION_SPACE_INSTEAD_NL,
                getKey(IEpsilonPreferences.OPTION_SPACE_INSTEAD_NL), BOOLEAN_VALUES, 0);
        addTextField(composite, LABEL_GENERATOR_ADDITIONAL_OPTIONS,
                getKey(IEpsilonPreferences.ADDITIONAL_GENERATOR_OPTIONS), 0, 0);
    }
    
    public String getKey(String preferenceName) {
        return languageName + PreferenceConstants.SEPARATOR + preferenceName;
    }

    @Override
    protected void validateSettings(String changedKey, String oldValue, String newValue) {
    }
    
    @Override
    public void dispose() {
        IDialogSettings settings = EpsilonActivator.getInstance().getDialogSettings().addNewSection(SETTINGS_SECTION_NAME);
        storeSectionExpansionStates(settings);
        super.dispose();
    }

    @Override
    protected String[] getFullBuildDialogStrings(boolean workspaceSettings) {
        String title = "Building Settings Changed"; //Messages.BuilderConfigurationBlock_SettingsChanged_Title;
        String message;
        if (workspaceSettings) {
            message = "The Building settings have changed. A full rebuild is required for changes to take effect. Do the full build now?"; // Messages.BuilderConfigurationBlock_SettingsChanged_WorkspaceBuild;
        } else {
            message = "The Building settings have changed. A rebuild of the project is required for changes to take effect. Build the project now?"; // Messages.BuilderConfigurationBlock_SettingsChanged_ProjectBuild;
        }
        return new String[] { title, message };
    }

    @Override
    protected Job getBuildJob(IProject project) {
        Job buildJob = new OptionsConfigurationBlock.BuildJob("Rebuilding", project); // Mssages.BuilderConfigurationBlock_BuildJob_Title0
        buildJob.setRule(ResourcesPlugin.getWorkspace().getRuleFactory().buildRule());
        buildJob.setUser(true);
        return buildJob;
    }

    @Override
    public String getPropertyPrefix() {
        return languageName;
    }

}
