package de.grammarcraft.epsilon.properties;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ProjectScope;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.osgi.service.prefs.BackingStoreException;

import de.grammarcraft.epsilon.preferences.EpsilonPreferences;
import static de.grammarcraft.epsilon.preferences.EpsilonPreferences.*;

/**
 * @author denis
 *
 */
public final class Properties {

    public static final String getGeneratorExecutablePath(IProject project) {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        return node.get(PROPERTY_GENERATOR_EXE_PATH, EpsilonPreferences.getGeneratorExecutablePath());
    }

    public static String getGeneratorTargetDir(IProject project) {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        return node.get(PROPERTY_GENERATOR_TARGET_DIR, EpsilonPreferences.getGeneratorTargetDir());
    }
    
    public static boolean getNoConstantTreesCollapsing(IProject project) {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        return node.getBoolean(PROPERTY_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING, EpsilonPreferences.getNoConstantTreesCollapsing());
    }
    
    public static boolean getGenerationOnly(IProject project) {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        return node.getBoolean(PROPERTY_GENERATOR_OPTION_GENERATION_ONLY, EpsilonPreferences.getGenerationOnly());
    }
    
    public static boolean getNoOptimization(IProject project) {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        return node.getBoolean(PROPERTY_GENERATOR_OPTION_NO_OPTIMIZATION, EpsilonPreferences.getNoOptimization());
    }
    
    public static boolean getNoReferenceCounting(IProject project) {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        return node.getBoolean(PROPERTY_GENERATOR_OPTION_NO_REFERENCE_COUNTING, EpsilonPreferences.getNoReferenceCounting());
    }
    
    public static boolean getIgnoreTokenMarks(IProject project) {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        return node.getBoolean(PROPERTY_GENERATOR_OPTION_IGNORE_TOKEN_MARKS, EpsilonPreferences.getIgnoreTokenMarks());
    }    

    public static final boolean getSpaceInsteadNL(IProject project) {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        return node.getBoolean(PROPERTY_GENERATOR_OPTION_SPACE_INSTEAD_NL, EpsilonPreferences.getSpaceInsteadNL());
    }

    public static String getAdditionalGeneratorOptions(IProject project) {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        return node.get(PROPERTY_GENERATOR_ADDITIONAL_OPTIONS, EpsilonPreferences.getAdditionalGeneratorOptions());
    }


    public static void storeGeneratorExecutablePath(IProject project, String newValue) throws BackingStoreException {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        node.put(PROPERTY_GENERATOR_EXE_PATH, newValue);
        node.flush();
    }

    public static void storeGeneratorTargetDir(IProject project, String newValue) throws BackingStoreException {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        node.put(PROPERTY_GENERATOR_TARGET_DIR, newValue);
        node.flush();
    }
    
    public static void storeNoConstantTreesCollapsing(IProject project, boolean newValue) throws BackingStoreException {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        node.putBoolean(PROPERTY_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING, newValue);
        node.flush();
    }
    
    public static void storeGenerationOnly(IProject project, boolean newValue) throws BackingStoreException {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        node.putBoolean(PROPERTY_GENERATOR_OPTION_GENERATION_ONLY, newValue);
        node.flush();
    }
    
    public static void storeNoOptimization(IProject project, boolean newValue) throws BackingStoreException {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        node.putBoolean(PROPERTY_GENERATOR_OPTION_NO_OPTIMIZATION, newValue);
        node.flush();
    }
    
    public static void storeNoReferenceCounting(IProject project, boolean newValue) throws BackingStoreException {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        node.putBoolean(PROPERTY_GENERATOR_OPTION_NO_REFERENCE_COUNTING, newValue);
        node.flush();
    }
    
    public static void storeIgnoreTokenMarks(IProject project, boolean newValue) throws BackingStoreException {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        node.putBoolean(PROPERTY_GENERATOR_OPTION_IGNORE_TOKEN_MARKS, newValue);
        node.flush();
    }

    public static void storeSpaceInsteadNL(IProject project, boolean newValue) throws BackingStoreException {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        node.putBoolean(PROPERTY_GENERATOR_OPTION_SPACE_INSTEAD_NL, newValue);
        node.flush();
    }

    public static void storeAdditionalGeneratorOptions(IProject project, String newValue) throws BackingStoreException {
        IEclipsePreferences node = new ProjectScope(project).getNode(LANGUAGE_NAME);
        node.put(PROPERTY_GENERATOR_ADDITIONAL_OPTIONS, newValue);
        node.flush();
    }
}
