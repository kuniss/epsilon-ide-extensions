/**
 * 
 */
package de.grammarcraft.epsilon.ui.config;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.jface.preference.IPreferencePageContainer;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer;
import org.eclipse.xtext.Constants;
import org.eclipse.xtext.ui.preferences.PropertyAndPreferencePage;

import com.google.inject.Inject;
import com.google.inject.name.Named;

/**
 * @author Michael Clay - Initial contribution and API
 * @since 2.1
 */
public class EpsilonPreferencePage extends PropertyAndPreferencePage {
    
    @Inject
    private EpsilonConfigurationBlock builderConfigurationBlock;
    
    private String languageName;

    @Inject
    public void setLanguageName(@Named(Constants.LANGUAGE_NAME) String languageName) {
        this.languageName = languageName;
    }

    @Override
    public void createControl(Composite parent) {
        IWorkbenchPreferenceContainer container = (IWorkbenchPreferenceContainer) getContainer();
        builderConfigurationBlock.setProject(getProject());
        builderConfigurationBlock.setWorkbenchPreferenceContainer(container);
        builderConfigurationBlock.setStatusChangeListener(getNewStatusChangedListener());
        super.createControl(parent);
    }

    @Override
    protected Control createPreferenceContent(Composite composite, IPreferencePageContainer preferencePageContainer) {
        return builderConfigurationBlock.createContents(composite);
    }

    @Override
    protected boolean hasProjectSpecificOptions(IProject project) {
        return builderConfigurationBlock.hasProjectSpecificOptions(project);
    }

    @Override
    protected String getPreferencePageID() {
        return languageName + ".generator.preferencePage";
    }

    @Override
    protected String getPropertyPageID() {
        return languageName + ".generator.propertyPage";
    }

    @Override
    public void dispose() {
        if (builderConfigurationBlock != null) {
            builderConfigurationBlock.dispose();
        }
        super.dispose();
    }

    @Override
    protected void enableProjectSpecificSettings(boolean useProjectSpecificSettings) {
        super.enableProjectSpecificSettings(useProjectSpecificSettings);
        if (builderConfigurationBlock != null) {
            builderConfigurationBlock.useProjectSpecificSettings(useProjectSpecificSettings);
        }
    }

    @Override
    protected void performDefaults() {
        super.performDefaults();
        if (builderConfigurationBlock != null) {
            builderConfigurationBlock.performDefaults();
        }
    }

    @Override
    public boolean performOk() {
        if (builderConfigurationBlock != null) {
            if (!builderConfigurationBlock.performOk()) {
                return false;
            }
        }
        return super.performOk();
    }

    @Override
    public void performApply() {
        if (builderConfigurationBlock != null) {
            builderConfigurationBlock.performApply();
        }
    }

    @Override
    public void setElement(IAdaptable element) {
        super.setElement(element);
        setDescription(null); // no description for property page
    }

}
